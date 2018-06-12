
class DifferController < ApplicationController

  def diff
    # This currently returns tags that are traffic-lights.
    # This matches the default tag handling in the review-controller.
    # The review/diff dialog/page has been refactored so it
    # works when sent either just traffic-lights or the full set of tags.
    # It does not yet have a way to select between these two options.
    # However if it is sent the full set of tags it must drop tag zero
    # (which is the _kata_ creation time). This is partly so that
    # the lowest tag.number is 1 (one) and not 0 (zero) as it is not
    # clear how to cleanly handle a tag of zero in diff-mode since it does
    # not have a previous tag. It is also partly because it makes sense
    # for the tags to correspond to actual kata/edit events.
    # So, in summary, if returning all the tags the first line needs to be
    #         tags = avatar.tags.map(&:to_json)
    #         tags.shift
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
