
class HttpSpy

  def initialize(_parent)
    clear
  end

  attr_reader :spied

  def clear
    @spied = []
  end

  def get(hostname, port, method, named_args)
    @spied << [ hostname, port, method.to_s, named_args ]
    { method.to_s => { 'stdout' => '', 'stderr' => '', 'status' => 0, 'colour' => 'amber' } }
  end

  def post(hostname, port, method, named_args)
    @spied << [ hostname, port, method.to_s, named_args ]
    { method.to_s => { 'stdout' => '', 'stderr' => '', 'status' => 0, 'colour' => 'amber' } }
  end

end
