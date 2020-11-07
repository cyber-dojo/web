# frozen_string_literal: true

require 'json'

module HttpJson

  class Responder

    def initialize(requester, exception_class, options = {})
      @requester = requester
      @exception_class = exception_class
      @options = options
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.body, path.to_s)
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def post(path, args)
      response = @requester.post(path, args)
      unpacked(response.body, path.to_s)
    end

    private

    def unpacked(body, path)
      json = json_parse(body)
      unless json.is_a?(Hash) || json.is_a?(Array)
        throw error_msg(body, 'is not JSON Hash|Array')
      end
      if json.is_a?(Hash) && json.has_key?('exception')
        throw JSON.pretty_generate(json['exception'])
      end
      if @options[:keyed]
        unless json.has_key?(path)
          throw error_msg(body, "has no key for '#{path}'")
        end
        json[path]
      else
        json
      end
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def json_parse(body)
      JSON.parse(body)
    rescue JSON::ParserError
      throw error_msg(body, 'is not JSON')
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def error_msg(body, text)
      "http response.body #{text}:#{body}"
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def throw(message)
      fail @exception_class, message
    end

  end

end
