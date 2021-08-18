# frozen_string_literal: true

require 'forwardable'

module Spiderb
  # Represents a URL to be crawled or downloaded
  class URL
    extend Forwardable

    attr_reader :uri

    delegate %i[host path request_uri to_s] => :uri
    delegate %i[hash] => :to_s

    alias to_str to_s

    def self.of(value)
      case value
      when Spiderb::URL then value
      when String then string(value)
      when URI then uri(value)
      else raise ArgumentError, "Unknown URL type #{value.class}"
      end
    end

    def self.string(value)
      uri(URI(value))
    end

    def self.uri(value)
      new(uri: value)
    end

    def initialize(uri:)
      @uri = uri.dup.normalize
      @uri.fragment = nil
    end

    def eql?(other)
      to_s.eql? URL.of(other).to_s
    end
    alias == eql?

    def <=>(other)
      to_s <=> URL.of(other).to_s
    end

    def merge(other)
      URL.new(uri: @uri.merge(other))
    end

    def route_from(base)
      uri.route_from(URL.of(base).uri)
    end

    def route_to(other)
      uri.route_to(URL.of(other).uri)
    end

    def start_with?(base)
      uri.to_s.start_with?(URL.of(base).to_s)
    end

    def inspect
      "<##{self.class} #{self}>"
    end
  end
end
