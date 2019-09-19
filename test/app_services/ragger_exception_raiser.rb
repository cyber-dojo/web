require_relative '../../app/services/ragger_exception'

class RaggerExceptionRaiser

  def initialize(_externals)
  end

  def method_missing(_m, *_args, &_block)
    raise RaggerException.new('stub-raiser')
  end

end
