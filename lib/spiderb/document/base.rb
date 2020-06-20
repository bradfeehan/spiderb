# frozen_string_literal: true

module Spiderb
  module Document
    # Base document type, with no links
    class Base
      attr_reader :body, :type, :url

      def initialize(body:, type:, url:)
        @body = body
        @type = type
        @url = url
      end

      def links
        []
      end

      def rewrite_links; end
    end
  end
end
