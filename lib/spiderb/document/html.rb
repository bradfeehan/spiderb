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
        script: 'src'
      }.freeze

      TAGS_XPATH = "(#{TAGS.map { |tag, attr| "//#{tag}/@#{attr}" }.join('|')})"

      def body
        nokogiri.to_s
      end

      def links
        nokogiri.xpath(TAGS_XPATH)
      end

      def rewrite_links
        links.each do |node|
          value = yield node
          node.content = value unless value.nil?
        end
      end

      private

      def nokogiri
        @nokogiri ||= Nokogiri.HTML(@body)
      end
    end
  end
end
