require 'date'
require 'multi_json'
require 'elasticsearch/api'
require 'pry'
require 'fileutils'
require 'faraday'

class MySimpleClient
  include Elasticsearch::API
  CONNECTION = ::Faraday::Connection.new url: 'http://localhost:9200'
  def perform_request(method, path, params, body)
    puts "--> #{method.upcase} #{path} #{params} #{body}"
    CONNECTION.run_request \
      method.downcase.to_sym,
      path,
      (body ? MultiJson.dump(body) : nil),
      'Content-Type' => 'application/json'
  end
end

client = MySimpleClient.new
user = `whoami`.delete("\n")

FileUtils.cd("/Users/#{user}/Desktop/website_widget_data-5-15-18") do
  files = `ls`.split("\n")
  # time = Time.now.utc.to_date.to_s
  desired_keys = %w[event_text device timestamp session_id token]
  files.each do |file|
    # Add the event data as the second element in the array
    parsed = MultiJson.load(File.read(file))
    # Remove keys from the event data that we don't need in Elasticsearch
    without_keys = parsed.first.reject do |k, v|
      !desired_keys.include?(k) || v.nil? || v.empty?
    end
    # Push data into Elasticsearch
    p client.index(
      index: "webchat-#{without_keys['timestamp'].split(' ').first}",
      type: 'analytic-event',
      body: without_keys
    )
  end
end
