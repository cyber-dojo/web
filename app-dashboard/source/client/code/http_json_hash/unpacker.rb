require_relative 'service_error'
require 'json'

module HttpJsonHash
  class Unpacker
    def initialize(name, requester)
      @name = name
      @requester = requester
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.body, path.to_s, args)
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def post(path, args)
      response = @requester.post(path, args)
      unpacked(response.body, path.to_s, args)
    end

    private

    def unpacked(body, path, args)
      json = JSON.parse!(body)
      error = hash_error(json, path)
      service_error(path, args, body, error) if error
      json[path]
    rescue JSON::ParserError
      service_error(path, args, body, 'body is not JSON')
    end

    # The message describing the first problem with the parsed body, or nil if
    # it is a Hash carrying the requested path's key and no embedded exception.
    def hash_error(json, path)
      return 'body is not JSON Hash' unless json.instance_of?(Hash)
      return 'body has embedded exception' if json.key?('exception')
      return 'body is missing :path key' unless json.key?(path)

      nil
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def service_error(path, args, body, message)
      raise ::HttpJsonHash::ServiceError.new(path, args, @name, body, message)
    end
  end
end
