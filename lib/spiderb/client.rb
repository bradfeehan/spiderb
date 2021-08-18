# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'
require 'forwardable'

module Spiderb
  # HTTP client
  class Client
    extend Forwardable

    # delegate %i[get] => :connection

    def get(url)
      connection.get(url) do |request|
        request.headers[:user_agent] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Safari/605.1.15'

      end
    end

    private

    def connection
      @connection ||= Faraday.new do |f|
        f.use :cookie_jar
        f.use FaradayMiddleware::FollowRedirects, limit: 5
        f.adapter Faraday.default_adapter
      end
    end
  end
end
