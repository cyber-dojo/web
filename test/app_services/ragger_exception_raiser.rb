require_relative '../../app/services/ragger_service'

class RaggerExceptionRaiser

  def initialize(_externals)
  end

  def method_missing(_m, *_args, &_block)
    raise RaggerService::Error.new('stub-raiser')
  end

end
