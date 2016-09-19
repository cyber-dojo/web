
require 'net/http'

module GitDiffService # mix-in

  def avatar_git_diff(avatar, was_tag, now_tag)
    diff_params = {
      :was_files => avatar.tags[was_tag].visible_files.to_json,
      :now_files => avatar.tags[now_tag].visible_files.to_json
    }
    uri = URI.parse(ENV['DIFFER_PORT'].sub('tcp', 'http') + '/diff')
    uri.query = URI.encode_www_form(diff_params)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end

end
