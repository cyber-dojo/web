require_relative 'http_service_exception'

class RaggerException < HttpServiceException

  def initialize(message)
    super
  end

end
