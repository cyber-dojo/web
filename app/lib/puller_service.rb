require 'json'
require 'net/http'

class PullerService

  def initialize(_parent)
  end

  def pulled?(image_name)
    name = __method__.to_s
    json = http(name, { 'image_name' => image_name }) do |uri|
      Net::HTTP::Get.new(uri)
    end
    result(json, name)
  end

  def pull(image_name)
    name = __method__.to_s
    json = http(name, { 'image_name' => image_name }) do |uri|
      Net::HTTP::Post.new(uri)
    end
    result(json, name)
  end

  private

  def http(method, args)
    uri = URI.parse('http://puller:4547/' + method)
    http = Net::HTTP.new(uri.host, uri.port)
    request = yield uri.request_uri
    request.content_type = 'application/json'
    request.body = args.to_json
    response = http.request(request)
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
    StandardError.new("PullerService:#{name}:#{message}")
  end

end
