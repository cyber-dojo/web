require_relative '../../app/services/saver_exception'

class SaverExceptionRaiser

  def initialize(_externals)
  end

  def method_missing(_m, *_args, &_block)
    raise SaverException.new('stub-raiser')
  end

end
