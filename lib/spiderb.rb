# frozen_string_literal: true

require 'spiderb/crawler'
require 'spiderb/version'

# A web crawler written in Ruby
module Spiderb
  class Error < StandardError; end

  def self.crawl(url, to:)
    Crawler.new(url: url, destination: to).start
  end
end
