require 'json'
require 'net/http'
require 'uri'

module Web
  module HttpJson
    class Requester
      def initialize(http, hostname, port)
        @http = http
        @hostname = hostname
        @port = port
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

      # Builds the request and sends it through an http object of its own.
      # Net::HTTP#request mutates the object's socket and started flags, so an
      # object shared by the threads serving concurrent requests would have them
      # overwriting each other's connection state. Its own object costs nothing:
      # the object is never started, so #request opens a connection, sends with
      # Connection: close, and closes it, holding no connection to reuse.
      def packed(path, args)
        uri = URI.parse("#{@base_url}/#{path}")
        req = yield uri
        req.content_type = 'application/json'
        req.body = JSON.generate(args)
        @http.new(@hostname, @port).request(req)
      end
    end
  end
end
