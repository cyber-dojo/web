# frozen_string_literal: true

require_relative '../services/saver_service'

module SaverAsserter # mix-in

  def saver_assert(command)
    result = saver.send(*command)
    unless result
      # TODO: diagnostic = command+result
      fail SaverService::Error.new('false')
    end
    result
  end

  def saver_assert_batch(*commands)
    results = saver.batch(commands)
    if results.any?(false)
      # TODO: diagnostic = commmands+results
      fail SaverService::Error.new(results.inspect)
    end
    results
  end

end
