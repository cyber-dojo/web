require 'json'
require 'net/http'

module HttpHelper # mix-in

  module_function

  def http_get(method, *args)
    http_get_hash(method, args_hash(method, *args))
  end

  def http_get_hash(method, args_hash)
    json = http('GET', hostname, port, method, args_hash)
    result(json, method.to_s)
  end

  # - - - - - - - - - - - - - - - - - - -

  def http_post(method, *args)
    http_post_hash(method, args_hash(method, *args))
  end

  def http_post_hash(method, args_hash)
    json = http('POST', hostname, port, method, args_hash)
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

  def http(gp, hostname, port, method, named_args)
    uri = URI.parse("http://#{hostname}:#{port}/" + method.to_s)
    request = Net::HTTP:: Get.new(uri) if gp == 'GET'
    request = Net::HTTP::Post.new(uri) if gp == 'POST'
    request.content_type = 'application/json'
    request.body = named_args.to_json
    service = Net::HTTP.new(uri.host, uri.port)
    response = service.request(request)
    JSON.parse(response.body)
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

end
