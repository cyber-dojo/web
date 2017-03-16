require 'json'
require 'net/http'

module HttpService # mix-in

  module_function

  def get(method, *args)
    name = method.to_s
    http(name, args_hash(name, *args)) { |uri|
      Net::HTTP::Get.new(uri)
    }
  end

  def post(method, *args)
    name = method.to_s
    http(name, args_hash(name, *args)) { |uri|
      Net::HTTP::Post.new(uri)
    }
  end

  def http(method, args)
    uri = URI.parse("http://#{hostname}:#{port}/" + method)
    request = yield uri.request_uri
    request.content_type = 'application/json'
    request.body = args.to_json
    service = Net::HTTP.new(uri.host, uri.port)
    response = service.request(request)
    json = JSON.parse(response.body)
    result(json, method)
  end

  def args_hash(method, *args)
    parameters = self.class.instance_method(method).parameters
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

end
