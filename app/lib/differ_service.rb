require 'net/http'
require 'json'
require_relative '../../lib/nearest_ancestors'

class DifferService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def diff(avatar, was_tag, now_tag)
    # See https://github.com/cyber-dojo/commander and its docker-compose.yml
    uri = URI.parse('http://differ:4567')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = 'application/json'
    hash = storer.tags_visible_files(avatar.kata.id, avatar.name, was_tag, now_tag)
    request.body = {
      :was_files => hash['was_tag'], #avatar.tags[was_tag].visible_files,
      :now_files => hash['now_tag']  #avatar.tags[now_tag].visible_files
    }.to_json
    response = http.request(request)
    JSON.parse(response.body)
  end

  private

  include NearestAncestors
  def storer; nearest_ancestors(:storer); end

end
