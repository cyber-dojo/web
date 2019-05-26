
class HttpSpy

  def initialize(_parent)
    clear
  end

  attr_reader :spied

  def clear
    @spied = []
  end

  def stub(response)
    @response = response
  end

  def get(hostname, port, method, args)
    @spied << [ hostname, port, method.to_s, args ]
    { method.to_s => @response }
  end

  def post(hostname, port, method, args)
    @spied << [ hostname, port, method.to_s, args ]
    { method.to_s => @response }
  end

end
