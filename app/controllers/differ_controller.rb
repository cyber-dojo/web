
require 'net/http'

class DifferController < ApplicationController

  def diff
    @lights = avatar.lights.map(&:to_json)

    diff_params = {
      :was_files => avatar.tags[was_tag].visible_files.to_json,
      :now_files => avatar.tags[now_tag].visible_files.to_json
    }
    uri = URI.parse(ENV['DIFFER_PORT'].sub('tcp', 'http') + '/diff')
    uri.query = URI.encode_www_form(diff_params)
    response = Net::HTTP.get_response(uri)
    json = JSON.parse(response.body)
    diffs = git_diff_view(json)

    render json: {
                         id: kata.id,
                     avatar: avatar.name,
                     wasTag: was_tag,
                     nowTag: now_tag,
                     lights: @lights,
	                    diffs: diffs,
                 prevAvatar: ring_prev(active_avatar_names, avatar.name),
                 nextAvatar: ring_next(active_avatar_names, avatar.name),
	      idsAndSectionCounts: prune(diffs),
          currentFilenameId: pick_file_id(diffs, current_filename),
	  }
  end

  private

  include DifferWorker

end
