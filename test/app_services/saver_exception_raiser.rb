# frozen_string_literal: true

class SaverExceptionRaiser

  def initialize(_externals)
  end

  def method_missing(_m, *_args, &_block)
    raise SaverService::Error.new('saver-exception-raiser')
  end

end
