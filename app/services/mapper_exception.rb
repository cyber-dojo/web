# frozen_string_literal: true

require_relative 'http_service_exception'

class MapperException < HttpServiceException

  def initialize(message)
    super
  end

end
