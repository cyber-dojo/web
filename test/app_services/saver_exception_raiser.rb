require_relative '../../app/services/saver_service'

class SaverExceptionRaiser

  def initialize(_externals)
  end

  def method_missing(_m, *_args, &_block)
    raise SaverService::Error.new('stub-raiser')
  end

end
