require_relative 'http_helper'

class PorterService

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - -

  def sha
    http_get(__method__)
  end

  # - - - - - - - - - - - -

  def port(id)
    http_post(__method__, id)
  end

  private

  include HttpHelper

  def hostname
    'porter'
  end

  def port
    4517
  end

end
