require_relative 'requester'
require_relative 'unpacker'

module HttpJsonHash
  def self.service(name, http, hostname, port)
    requester = Requester.new(http, hostname, port)
    Unpacker.new(name, requester)
  end
end
