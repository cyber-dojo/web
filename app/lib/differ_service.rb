require 'net/http'
require 'json'
require_relative '../../lib/nearest_ancestors'

class DifferService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def diff(avatar, was_tag, now_tag)
    # See https://github.com/cyber-dojo/commander
    # and its docker-compose.yml
    uri = URI.parse('http://differ:4567')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = 'application/json'
    args = []
    args << avatar.kata.id
    args << avatar.name
    args << was_tag
    args << now_tag
    visible_files = storer.tags_visible_files(*args)
    request.body = {
      :was_files => visible_files['was_tag'],
      :now_files => visible_files['now_tag']
    }.to_json
    response = http.request(request)
    JSON.parse(response.body)
  end

  private

  include NearestAncestors
  def storer; nearest_ancestors(:storer); end

end
