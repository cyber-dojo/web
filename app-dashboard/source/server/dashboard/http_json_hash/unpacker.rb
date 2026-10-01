require_relative 'service_error'
require 'json'

module DashboardApp
  module HttpJsonHash
    class Unpacker
      def initialize(name, requester)
        @name = name
        @requester = requester
      end

      def get(path, args)
        response = @requester.get(path, args)
        unpacked(response, path.to_s, args)
      end

      # post is called only by the fixture scripts in test/scripts
      # simplecov:disable
      def post(path, args)
        response = @requester.post(path, args)
        unpacked(response, path.to_s, args)
      end
      # simplecov:enable

      private

      def unpacked(response, path, args)
        json = JSON.parse!(response.body)
        error = hash_error(json, path)
        service_error(response, path, args, error) if error
        json[path]
      rescue JSON::ParserError
        service_error(response, path, args, 'body is not JSON')
      end

      # The message describing the first problem with the parsed body, or nil if
      # it is a Hash carrying the requested path's key and no embedded
      # exception.
      def hash_error(json, path)
        return 'body is not JSON Hash' unless json.instance_of?(Hash)
        return 'body has embedded exception' if json.key?('exception')
        return 'body is missing :path key' unless json.key?(path)

        nil
      end

      def service_error(response, path, args, message)
        raise HttpJsonHash::ServiceError.new(
          path, args, @name, response.body, response.code, message
        )
      end
    end
  end
end
