
class DifferController < ApplicationController

  def diff
    tags = avatar.tags.map(&:to_json)
    was_tag = get_tag(:was_tag, tags.length)
    now_tag = get_tag(:now_tag, tags.length)
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

  def get_tag(name, size)
    raw = params[name].to_i
    raw != -1 ? raw : size
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
