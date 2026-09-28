require 'net/http'

class ExternalHttp
  def get(uri)
    KLASS::Get.new(uri)
  end

  def post(uri)
    KLASS::Post.new(uri)
  end

  def start(hostname, port, req)
    KLASS.start(hostname, port) do |http|
      http.request(req)
    end
  end

  KLASS = Net::HTTP
end
