require_relative 'http_service_exception'

class VersionerException < HttpServiceException

  def initialize(message)
    super
  end

end
