require_relative '../../lib/nearest_ancestors'

module HttpHelper # mix-in

  module_function

  def http_get(method, *args)
    http_get_hash(method, args_hash(method, *args))
  end

  def http_post(method, *args)
    http_post_hash(method, args_hash(method, *args))
  end

  # - - - - - - - - - - - - - - - - - - -

  def http_get_hash(method, args_hash)
    json = http.get(hostname, port, method, args_hash)
    result(json, method.to_s)
  end

  def http_post_hash(method, args_hash)
    json = http.post(hostname, port, method, args_hash)
    result(json, method.to_s)
  end

  # - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - -

  def args_hash(method, *args)
    parameters = self.class.instance_method(method.to_s).parameters
    Hash[parameters.map.with_index { |parameter,index|
      [parameter[1], args[index]]
    }]
  end

  def result(json, name)
    fail error(name, 'bad json') unless json.class.name == 'Hash'
    exception = json['exception']
    fail error(name, exception)  unless exception.nil?
    fail error(name, 'no key')   unless json.key? name
    json[name]
  end

  def error(name, message)
    StandardError.new("#{self.class.name}:#{name}:#{message}")
  end

  include NearestAncestors

  def http
    nearest_ancestors(:http)
  end

end
