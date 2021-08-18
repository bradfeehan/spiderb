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
    THREAD_COUNT = 32

    attr_reader :base_urls, :initial_url

    def initialize(base_urls:, initial_url:, tags:, destination:)
      @base_urls = base_urls.map { |base_url| URL.of(base_url) }
      @tags = tags
      @client = Client.new
      @persistence = Persistence.new(destination: destination, tags: tags)
      @semaphore = Mutex.new
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @unvisited = SortedSet.new([URL.of(initial_url)])
      @visiting = SortedSet.new
      @visited = SortedSet.new
    end

    def start
      threads = THREAD_COUNT.times.map do |index|
        # puts "[thread #{index}] starting"
        Thread.new do
          Thread.current[:id] = index
          # puts "[thread #{Thread.current[:id]}] started"
          catch :done do
            loop do
              # puts "[thread #{Thread.current[:id]}] looping"
              while (url = next_url)
                visit(url)
                # puts "[thread #{Thread.current[:id]}] visited"
              end

              @semaphore.synchronize do
                # puts "[thread #{Thread.current[:id]}] sleeping"
                @condition.wait(@semaphore)
                # puts "[thread #{Thread.current[:id]}] awoken"
              end
            end
          end
          puts "[thread #{Thread.current[:id]}] done"
          @semaphore.synchronize { @condition.broadcast }
        end
      end

      threads.each(&:join)
      puts "All threads done, re-writing links"
      @persistence.rewrite_links
    end

    private

    def visit(url)
      sleep 3
      puts "[thread #{Thread.current[:id]}] visiting #{url}"
      response = @client.get(url.uri)
      document = Document.of(response, url: url, tags: @tags)
      @persistence.save(document)
      add(document.links, url: url)
      mark_visited(url)
    end

    def add(links, url:)
      # puts "Adding #{links.count} links"
      urls = links
        .map { |href| url.merge(href) }
        .select { |href| base_urls.any? { |base| href.start_with?(base) } }

      @mutex.synchronize { @unvisited.merge(urls) }
    end

    def mark_visited(url)
      @mutex.synchronize do
        # puts "Marking visited: #{url}"
        @visiting.delete(url)
        @visited.add(url)
      end
      @semaphore.synchronize { @condition.signal }
    end

    def next_url
      @mutex.synchronize do
        if @unvisited.empty?
          if @visiting.empty?
            # puts "[thread #{Thread.current[:id]}] next_url: DONE"
            throw :done
            return nil
          else
            # puts "[thread #{Thread.current[:id]}] next_url: None, but some in visiting (#{@visiting})"
            return nil
          end
        end

        url = nil
        begin
          url = @unvisited.first.tap { |url| @unvisited.delete(url) }
        end while @visited.include?(url) || @visiting.include?(url)

        if url.nil?
          # puts "[thread #{Thread.current[:id]}] next_url: DONE"
          throw :done
        end

        # puts "[thread #{Thread.current[:id]}] next_url: visiting #{url}"
        @visiting.add(url)
        url
      end
    end
  end
end
