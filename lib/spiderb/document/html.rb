# frozen_string_literal: true

require 'nokogiri'

module Spiderb
  module Document
    # Represents a HTML document, with possible links contained within
    class HTML < Base
      TAGS = {
        a: 'href',
        img: 'src',
        link: 'href',
        script: 'src',
      }.freeze

      def initialize(body:, type:, url:, tags:)
        super(body: body, type: type, url: url)
        @tags = tags.nil? ? {} : tags
      end

      def body
        nokogiri.to_s
      end

      def links
        link_nodes.map(&:to_s).map(&:strip)
      end

      def rewrite_links
        link_nodes.each do |node|
          value = yield node
          node.content = value unless value.nil?
        end
      end

      private

      def nokogiri
        @nokogiri ||= Nokogiri.HTML(@body)
      end

      def link_nodes
        nokogiri.xpath(tags_xpath)
      end

      def tags_xpath
        xpaths = TAGS.merge(@tags).map { |tag, attr| "//#{tag}/@#{attr}" }
        '(' + xpaths.join('|') + ')'
      end
    end
  end
end
