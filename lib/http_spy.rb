
class HttpSpy

  def initialize(_parent)
  end

  attr_reader :hostname, :port, :method, :named_args

  def get(hostname, port, method, named_args)
    @hostname = hostname
    @port = port
    @method = method.to_s
    @named_args = named_args
    { @method => { 'stdout' => '', 'stderr' => '', 'status' => 0, 'colour' => 'amber' } }
  end

  def post(hostname, port, method, named_args)
    @hostname = hostname
    @port = port
    @method = method.to_s
    @named_args = named_args
    { @method => { 'stdout' => '', 'stderr' => '', 'status' => 0, 'colour' => 'amber' } }
  end

  def spied_hostname?(hostname)
    @hostname == hostname
  end

  def spied_named_arg?(symbol)
    @named_args.keys.include? symbol
  end

end
