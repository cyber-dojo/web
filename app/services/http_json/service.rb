# frozen_string_literal: true

require_relative 'request_packer'
require_relative 'response_unpacker'

module HttpJson

  def self.service(http, name, port, exception_class)
    requester = RequestPacker.new(http, name, port)
    ResponseUnpacker.new(requester, exception_class)
  end

end
