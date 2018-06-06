
class DifferController < ApplicationController

  def diff
    lights = avatar.lights.map(&:to_json)
    was_tag = tag(:was_tag, lights.length)
    now_tag = tag(:now_tag, lights.length)
    diff = differ.diff(kata.id, avatar.name, was_tag, now_tag)
    view = diff_view(diff)
    render json: {
                         id: kata.id,
                     avatar: avatar.name,
                     wasTag: was_tag,
                     nowTag: now_tag,
                     lights: lights,
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

  def tag(name, size)
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
