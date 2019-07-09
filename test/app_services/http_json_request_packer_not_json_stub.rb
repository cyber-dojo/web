require 'ostruct'

class HttpJsonRequestPackerNotJsonStub
  def initialize(_hostname, _port)
  end
  def request(_req)
    return OpenStruct.new(body:'sdgdfg')
  end
end
