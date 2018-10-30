require_relative 'service_error'
require 'json'

class HttpHelper

  def initialize(externals, parent, hostname, port)
    @externals = externals
    @parent = parent
    @hostname = hostname
    @port = port
  end

  def get(method, *args)
    json = http.get(@hostname, @port, method, args_hash(method, *args))
    result(json, method.to_s)
  end

  def post(method, *args)
    json = http.post(@hostname, @port, method, args_hash(method, *args))
    result(json, method.to_s)
  end

  private

  def args_hash(method, *args)
    parameters = @parent.class.instance_method(method.to_s).parameters
    Hash[parameters.map.with_index { |parameter,index|
      [parameter[1], args[index]]
    }]
  end

  def result(json, name)
    fail_unless(name, 'bad json') { json.class.name == 'Hash' }
    exception = json['exception']
    fail_unless(name, pretty(exception)) { exception.nil? }
    fail_unless(name, 'no key') { json.key?(name) }
    json[name]
  end

  def fail_unless(name, message, &block)
    unless block.call
      fail ServiceError.new(self.class.name, name, message)
    end
  end

  def pretty(json)
    JSON.pretty_generate(json)
  end

  def http
    @externals.http
  end

end
