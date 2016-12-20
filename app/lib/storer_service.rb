require 'json'
require 'net/http'

class StorerService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  # - - - - - - - - - - - -

  def path
    get(__method__)
  end

  # - - - - - - - - - - - -

  def create_kata(manifest)
    post(__method__, manifest)
  end

  def kata_manifest(kata_id)
    get(__method__, kata_id)
  end

  # - - - - - - - - - - - -

  def completed(id)
    get(__method__, id)
  end

  def completions(id)
    get(__method__, id)
  end

  # - - - - - - - - - - - -

  def start_avatar(kata_id, avatar_names)
    post(__method__, kata_id, avatar_names)
  end

  def started_avatars(kata_id)
    get(__method__, kata_id)
  end

  # - - - - - - - - - - - -

  def avatar_ran_tests(kata_id, avatar_name, files, now, output, colour)
    post(__method__, kata_id, avatar_name, files, now, output, colour)
  end

  # - - - - - - - - - - - -

  def avatar_increments(kata_id, avatar_name)
    get(__method__, kata_id, avatar_name)
  end

  def avatar_visible_files(kata_id, avatar_name)
    get(__method__, kata_id, avatar_name)
  end

  # - - - - - - - - - - - -

  def tag_visible_files(kata_id, avatar_name, tag)
    get(__method__, kata_id, avatar_name, tag)
  end

  private

  def get(method, *args)
    name = method.to_s
    json = http(name, args_hash(name, *args)) { |uri|
      Net::HTTP::Get.new(uri)
    }
    result(json, name)
  end

  def post(method, *args)
    name = method.to_s
    json = http(name, args_hash(name, *args)) { |uri|
      Net::HTTP::Post.new(uri)
    }
    result(json, name)
  end

  def http(method, args)
    uri = URI.parse('http://storer:4577/' + method)
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
    raise error(name, 'json.nil?') if json.nil?
    raise error(name, 'bad json') unless json.class.name == 'Hash'
    raise error(name, json['exception']) unless json['exception'].nil?
    raise error(name, 'no key') if json[name].nil?
    json[name]
  end

  def error(name, description)
    StandardError.new("StorerService:#{name}:#{description}")
  end

end
