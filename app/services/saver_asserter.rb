# frozen_string_literal: true

require_relative 'saver_exception'

module SaverAsserter # mix-in

  def saver_assert(truth)
    unless truth
      fail SaverException.new('false')
    end
  end

  def saver_assert_batch(*commands)
    result = saver.batch(commands)
    if result.any?(false)
      fail SaverException.new(result.inspect)
    end
    result
  end

end
