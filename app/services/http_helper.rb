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
    call(method, *args) { |args_hash|
      http.get(@hostname, @port, method.to_s, args_hash)
    }
  end

  def post(method, *args)
    call(method, *args) { |args_hash|
      http.post(@hostname, @port, method.to_s, args_hash)
    }
  end

  private

  def call(method, *args)
    method = method.to_s
    json = yield(args_hash(method, *args))
    result(json, method)
  end

  def args_hash(method, *args)
    # Uses reflection to create a hash of args where each key is
    # the parameter name. For example, differ_services does this
    #
    #   def diff(was_files, now_files)
    #     http.get(__method__, was_files, now_files)
    #  end
    #
    # Reflection sees the names of diff()'s parameters are
    # 'was_files' and 'now_files' and so constructs the hash
    # { 'was_files' => args[0], 'now_files' => args[1] }
    parameters = @parent.class.instance_method(method).parameters
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
