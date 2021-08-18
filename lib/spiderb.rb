# frozen_string_literal: true

require 'spiderb/crawler'
require 'spiderb/version'

# A web crawler written in Ruby
module Spiderb
  class Error < StandardError; end

  def self.crawl(initial_url, base_urls: nil, tags: nil, to:)
    base_urls = [initial_url] if base_urls.nil?

    crawler = Crawler.new(
      initial_url: initial_url,
      base_urls: base_urls,
      tags: tags,
      destination: to
    )

    crawler.start
  end
end
