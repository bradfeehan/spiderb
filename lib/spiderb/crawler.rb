# frozen_string_literal: true

require 'nokogiri'
require 'set'
require 'spiderb/client'
require 'spiderb/document'
require 'spiderb/persistence'
require 'spiderb/url'

module Spiderb
  # Main crawler algorithm
  class Crawler
    attr_reader :base_url, :destination

    def initialize(url:, destination:)
      @base_url = URL.of(url)
      @destination = destination
    end

    def start
      while (url = next_url)
        visit url unless visited.include? url
      end

      persistence.rewrite_links
    end

    private

    def visit(url)
      visited.add(url)
      puts "url = #{url}"

      response = client.get(url.uri)
      document = Document.of(response, url: url)

      add(document.links)

      persistence.save(document)
    end

    def client
      @client ||= Spiderb::Client.new
    end

    def persistence
      @persistence ||= Spiderb::Persistence.new(
        base_url: base_url,
        destination: destination
      )
    end

    def add(links)
      urls = links
        .map { |href| base_url.merge(href) }
        .select { |url| url.start_with?(base_url) }

      unvisited.merge(urls)
    end

    def next_url
      return nil if unvisited.empty?

      unvisited.first.tap { |url| unvisited.delete(url) }
    end

    def unvisited
      @unvisited ||= SortedSet.new([base_url])
    end

    def visited
      @visited ||= SortedSet.new
    end
  end
end
