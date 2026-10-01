require 'ostruct'

class HttpJsonRequesterNotJsonStub
  def initialize(_hostname, _port)
  end
  def request(_req)
    OpenStruct.new(body:'sdgdfg')
  end
end
