# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module HttpJson

  class Requester

    def initialize(http, hostname, port)
      @http = http.new(hostname, port)
      @base_url = "http://#{hostname}:#{port}"
    end

    def get(path, args)
      packed(path, args) do |url|
        Net::HTTP::Get.new(url)
      end
    end

    def post(path, args)
      packed(path, args) do |url|
        Net::HTTP::Post.new(url)
      end
    end

    private

    def packed(path, args)
      uri = URI.parse("#{@base_url}/#{path}")
      req = yield uri
      req.content_type = 'application/json'
      req.body = JSON.generate(args)
      @http.request(req)
    end

  end

end
