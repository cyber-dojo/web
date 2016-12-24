require 'net/http'
require 'json'
require_relative '../../lib/nearest_ancestors'

class DifferService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def diff(kata_id, avatar_name, was_tag, now_tag)
    # See https://github.com/cyber-dojo/commander
    # and its docker-compose.yml
    args = []
    args << kata_id
    args << avatar_name
    args << was_tag
    args << now_tag
    visible_files = storer.tags_visible_files(*args)
    was_files = visible_files['was_tag']
    now_files = visible_files['now_tag']
    raw_diff(was_files, now_files)
  end

  def raw_diff(was_files, now_files)
    json = http_get('diff', {
      :was_files => was_files,
      :now_files => now_files
    })
    result(json, 'diff')
  end

  private

  def http_get(method, args)
    uri = URI.parse('http://differ:4567/' + method)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = 'application/json'
    request.body = args.to_json
    response = http.request(request)
    JSON.parse(response.body)
  end

  def result(json, name)
    raise error(name, 'bad json') unless json.class.name == 'Hash'
    exception = json['exception']
    raise error(name, exception)  unless exception.nil?
    raise error(name, 'no key')   unless json.key? name
    json[name]
  end

  def error(name, message)
    StandardError.new("DifferService:#{name}:#{message}")
  end

  include NearestAncestors
  def storer; nearest_ancestors(:storer); end

end
