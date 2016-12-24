require 'json'
require 'net/http'

class RunnerService

  def initialize(_parent)
  end

  def pulled?(image_name)
    pulled(image_name)
  end

  def pulled(image_name)
    get(__method__, image_name)
  end

  def pull(image_name)
    post(__method__, image_name)
  end

  def new_kata(image_name, kata_id)
    post(__method__, image_name, kata_id)
  end

  def new_avatar(image_name, kata_id, avatar_name, starting_files)
    post(__method__, image_name, kata_id, avatar_name, starting_files)
  end

  def run(image_name, kata_id, avatar_name, deleted_filenames, changed_files, max_seconds)
    args = []
    args << image_name
    args << kata_id
    args << avatar_name
    args << deleted_filenames
    args << changed_files
    args << max_seconds
    sss = post(__method__, *args)
    [sss['stdout'], sss['stderr'], sss['status']]
  end

  def old_avatar(kata_id, avatar_name)
    post(__method__, kata_id, avatar_name)
  end

  def old_kata(kata_id)
    post(__method__, kata_id)
  end

  private

  def get(method, *args)
    name = method.to_s
    json = http(name, args_hash(name, *args)) do |uri|
      Net::HTTP::Get.new(uri)
    end
    result(json, name)
  end

  def post(method, *args)
    name = method.to_s
    json = http(name, args_hash(name, *args)) do |uri|
      Net::HTTP::Post.new(uri)
    end
    result(json, name)
  end

  def http(method, args)
    uri = URI.parse('http://runner:4557/' + method)
    http = Net::HTTP.new(uri.host, uri.port)
    request = yield uri.request_uri
    request.content_type = 'application/json'
    request.body = args.to_json
    response = http.request(request)
    JSON.parse(response.body)
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
    StandardError.new("RunnerService:#{name}:#{message}")
  end

end
