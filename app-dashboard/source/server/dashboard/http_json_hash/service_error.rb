module DashboardApp
  module HttpJsonHash
    class ServiceError < RuntimeError
      def initialize(path, args, name, body, status, message)
        @path = path
        @args = args
        @name = name
        @body = body
        @status = status
        super(message + "\n#{path}" + "\n#{body}")
      end
      attr_reader :path, :args, :name, :body, :status
    end
  end
end
