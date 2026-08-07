require 'json'

module Web
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
        raise exception_class.new(e.message)
      end

      # - - - - - - - - - - - - - - - - - - - - -

      def post(path, args)
        response = requester.post(path, args)
        unpacked(response.body, path.to_s, args)
      rescue Exception => e
        raise exception_class.new(e.message)
      end

      private

      attr_reader :requester, :exception_class

      def unpacked(body, path, args)
        json = JSON.parse!(body)
        unless json.is_a?(Hash)
          raise service_error(path, args, body, 'body is not JSON Hash')
        end
        if json.has_key?('exception')
          raise service_error(path, args, body, json['exception'])
        end
        unless json.has_key?(path)
          raise service_error(path, args, body, 'body is missing :path key')
        end

        json[path]
      rescue JSON::ParserError
        raise service_error(path, args, body, 'body is not JSON')
      end

      # Where diagnostics are written. Per-thread, so a test can capture what
      # one request logged without swapping the process-global $stdout that
      # every other concurrently-running request shares.
      def stdout_stream
        Thread.current[:stdout_stream] || $stdout
      end

      def service_error(path, args, body, message)
        stdout_stream.puts(JSON.pretty_generate({
          'Exception: HttpJson::Responder': {
            path: path,
            args: args,
            body: body,
            message: message
          }
        }))
        stdout_stream.flush
        exception_class.new(message)
      end
    end
  end
end
