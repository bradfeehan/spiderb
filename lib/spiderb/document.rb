# frozen_string_literal: true

require 'faraday'
require 'spiderb/document/base'
require 'spiderb/document/html'

module Spiderb
  # Represents a document of some type, either HTML, CSS, image, etc.
  module Document
    class << self
      def of(value, url:, tags:)
        case value
        when Spiderb::Document::Base
          value
        when Faraday::Response
          response(value, url: url, tags: tags)
        else
          raise ArgumentError, "Unknown document type #{value.class}"
        end
      end

      def response(value, url:, tags:)
        type = value.headers['content-type'].split(';').first.strip
        new(body: value.body, type: type, url: url, tags: tags)
      end

      def new(body:, type:, url:, tags: nil)
        case type
        when 'text/html'
          HTML.new(body: body, type: type, url: url, tags: tags)
        else
          Base.new(body: body, type: type, url: url)
        end
      end
    end
  end
end
