module DashboardApp
  module HttpJsonHash
    class ServiceError < RuntimeError
      def initialize(path, args, name, body, message)
        @path = path
        @args = args
        @name = name
        @body = body
        super(message + "\n#{path}" + "\n#{body}")
      end
      attr_reader :path, :args, :name, :body
    end
  end
end
