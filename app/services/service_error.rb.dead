require 'json'

class ServiceError < StandardError

  def initialize(service_name, method_name, message)
    @service_name = service_name
    @method_name = method_name
    super(message)
  end

  attr_reader :service_name, :method_name

end
