require 'bundler'
Bundler.require
require 'open-uri'
require 'json'

$:.unshift File.expand_path("./../lib", __FILE__)
require 'app/scrapper'

Scrapper.new.perform
