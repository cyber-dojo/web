require_relative 'service_error'
require 'json'

module CreatorApp
  module HttpJsonHash
    class Unpacker
      def initialize(name, requester)
        @name = name
        @requester = requester
      end

      attr_reader :name, :requester

      def get(path, args)
        response = @requester.get(path, args)
        unpacked(response, path.to_s, args)
      end

      def post(path, args)
        response = @requester.post(path, args)
        unpacked(response, path.to_s, args)
      end

      private

      def unpacked(response, path, args)
        json = JSON.parse!(response.body)
        return json unless json.is_a?(Hash)

        if json.key?('exception')
          service_error(response, path, args, 'body has embedded exception')
        end
        json.key?(path) ? json[path] : json
      rescue JSON::ParserError
        service_error(response, path, args, 'body is not JSON')
      end

      def service_error(response, path, args, message)
        raise HttpJsonHash::ServiceError.new(
          path, args, @name, response.body, response.code, message
        )
      end
    end
  end
end
