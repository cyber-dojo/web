# frozen_string_literal: true
require 'json'

module HttpJson

  class Responder

    def initialize(requester, exception_class)
      @requester = requester
      @exception_class = exception_class
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def get(path, args)
      response = requester.get(path, args)
      unpacked(response.body, path.to_s, args)
    rescue Exception => e
      fail exception_class.new(e.message)
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def post(path, args)
      response = requester.post(path, args)
      unpacked(response.body, path.to_s, args)
    rescue Exception => e
      fail exception_class.new(e.message)
    end

    private

    attr_reader :requester, :exception_class
    
    def unpacked(body, path, args)
      json = JSON.parse!(body)
      unless json.is_a?(Hash)
        fail service_error(path, args, body, 'body is not JSON Hash')
      end
      if json.has_key?('exception')
        fail service_error(path, args, body, json['exception'])
      end
      unless json.has_key?(path)
        fail service_error(path, args, body, 'body is missing :path key')
      end
      json[path]
    rescue JSON::ParserError
      fail service_error(path, args, body, 'body is not JSON')
    end

    def service_error(path, args, body, message)
      $stdout.puts(JSON.pretty_generate({
        "Exception: HttpJson::Responder": {
          path:path,
          args:args,
          body:body,
          message:message
        }
      }))
      $stdout.flush
      exception_class.new(message)
    end

  end

end
