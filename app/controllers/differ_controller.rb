
class DifferController < ApplicationController

  def diff
    @lights = avatar.lights.map(&:to_json)
    diff = avatar_git_diff(avatar, was_tag, now_tag)
    view = git_diff_view(diff)
    render json: {
                         id: kata.id,
                     avatar: avatar.name,
                     wasTag: was_tag,
                     nowTag: now_tag,
                     lights: @lights,
	                    diffs: view,
                 prevAvatar: ring_prev(active_avatar_names, avatar.name),
                 nextAvatar: ring_next(active_avatar_names, avatar.name),
	      idsAndSectionCounts: prune(view),
          currentFilenameId: pick_file_id(view, current_filename),
	  }
  end

  private

  include DifferWorker
  include GitDiffService
  include GitDiffView

end
