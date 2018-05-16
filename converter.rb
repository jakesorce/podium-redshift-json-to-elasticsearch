require 'json'
require 'elasticsearch'
require 'pry'
require 'fileutils'

FileUtils.cd("/Users/jakesorce/Desktop/website_widget_data-5-15-18") do
  files = `ls`.split("\n")
  files.each do |file|
    parsed = JSON.parse(File.read(file))
    # TODO: add ES header as first element in the array
    # Add the event data as the second element in the array
    # Remove keys from the event data that we don't need in Elasticsearch
    # Push data into elastic search
  end
end