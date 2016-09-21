
require 'net/http'

module GitDiffService # mix-in

  def avatar_git_diff(avatar, was_tag, now_tag)
    uri = URI.parse('http://differ:4567')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = 'application/json'
    request.body = {
      :was_files => avatar.tags[was_tag].visible_files,
      :now_files => avatar.tags[now_tag].visible_files
    }.to_json
    response = http.request(request)
    JSON.parse(response.body)
  end

end
