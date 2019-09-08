# frozen_string_literal: true

require_relative 'saver_exception'

module SaverAsserter # mix-in

  def saver_assert(truth)
    saver_assert_equal(true, truth)
  end

  def saver_assert_equal(result, expected)
    unless result === expected
      message = "expected:#{expected},"
      message += "actual:#{result}"
      fail SaverException.new(message)
    end
  end

end
