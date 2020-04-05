# frozen_string_literal: true

require_relative '../services/saver_service'
require_relative '../../lib/oj_adapter'

module SaverAsserter # mix-in

  def saver_assert(command)
    result = saver.public_send(*command)
    unless result
      name,arg0 = command
      message = saver_assert_info(name,arg0,result)
      raise SaverService::Error, json_plain(message)
    end
    result
  end

  include OjAdapter

  def saver_assert_info(name, arg0, result)
    { 'name' => name, 'arg[0]' => arg0, 'result' => result }
  end

end
