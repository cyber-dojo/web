
class HttpSpy

  def initialize(_parent)
    clear
  end

  attr_reader :spied, :hostname, :port, :method, :named_args

  def clear
    @spied = []
  end

  def get(hostname, port, method, named_args)
    @spied << [
      @hostname = hostname,
      @port = port,
      @method = method.to_s,
      @named_args = named_args
    ]
    { @method => { 'stdout' => '', 'stderr' => '', 'status' => 0, 'colour' => 'amber' } }
  end

  def post(hostname, port, method, named_args)
    @spied << [
      @hostname = hostname,
      @port = port,
      @method = method.to_s,
      @named_args = named_args
    ]
    { @method => { 'stdout' => '', 'stderr' => '', 'status' => 0, 'colour' => 'amber' } }
  end

  def spied_hostname?(hostname)
    @hostname == hostname
  end

  def spied_named_arg?(symbol)
    @named_args.keys.include? symbol
  end

end
