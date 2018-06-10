
class DifferController < ApplicationController

  def diff
    # This currently returns tags that are traffic-lights.
    # The matches the default tag handling in the review-controller.
    # The review/diff dialog/page has been refactored so it
    # works when sent either lights or the full set of tags.
    # However, it does not yet have a way to select between these
    # two options.
    tags = avatar.lights.map(&:to_json)
    was_tag, now_tag = *was_now(tags)
    diff = differ.diff(kata.id, avatar.name, was_tag, now_tag)
    view = diff_view(diff)
    render json: {
                         id: kata.id,
                     avatar: avatar.name,
                     wasTag: was_tag,
                     nowTag: now_tag,
                       tags: tags,
                      diffs: view,
                 prevAvatar: ring_prev(active_avatar_names, avatar.name),
                 nextAvatar: ring_next(active_avatar_names, avatar.name),
	      idsAndSectionCounts: prune(view),
          currentFilenameId: pick_file_id(view, current_filename),
	  }
  end

  private

  include DiffView
  include RingPicker
  include ReviewFilePicker

  def was_now(tags)
    # You only get -1 when in non-diff mode and you switch to a
    # new avatar in which case was_tag==-1 and now_tag==-1
    was = params[:was_tag].to_i
    now = params[:now_tag].to_i
    was = tags[-1]['number'] if was == -1
    now = tags[-1]['number'] if now == -1
    [was,now]
  end

  def current_filename
    params[:filename]
  end

  def active_avatar_names
    @active_avatar_names ||= avatars.active.map(&:name).sort
  end

  def prune(array)
    array.map { |hash| {
      :id            => hash[:id],
      :section_count => hash[:section_count]
    }}
  end

end
