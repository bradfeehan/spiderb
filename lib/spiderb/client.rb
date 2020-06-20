# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'forwardable'

module Spiderb
  # HTTP client
  class Client
    extend Forwardable

    delegate %i[get] => :connection

    private

    def connection
      @connection ||= Faraday.new do |f|
        f.use FaradayMiddleware::FollowRedirects, limit: 5
        f.adapter Faraday.default_adapter
      end
    end
  end
end
