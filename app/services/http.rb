require 'json'
require 'net/http'

class Http

  def initialize(_parent)
  end

  def get(hostname, port, path, named_args)
    call(hostname, port, path, named_args) { |url|
      Net::HTTP::Get.new(url)
    }
  end

  def post(hostname, port, path, named_args)
    call(hostname, port, path, named_args) { |url|
      Net::HTTP::Post.new(url)
    }
  end

  private

  def call(hostname, port, path, named_args)
    url = URI.parse("http://#{hostname}:#{port}/" + path)
    req = yield url
    req.content_type = 'application/json'
    req.body = named_args.to_json
    service = Net::HTTP.new(url.host, url.port)
    response = service.request(req)
    JSON.parse(response.body)
  end

end
