require_relative '../helpers/prev_next_avatar_ids_helper'

class DifferController < ApplicationController

  def diff
    version = params[:version].to_i
    id = params[:id]
    manifest,events,old_files,new_files = kata.diff_info(was_index, now_index)
    # ensure stdout/stderr/status show no diff
    old_files['stdout'] = new_files['stdout']
    old_files['stderr'] = new_files['stderr']
    old_files['status'] = new_files['status']
    diff = differ.diff(id, old_files, new_files)
    view = diff_view(diff)
    m = Manifest.new(manifest)
    exts = m.filename_extension
    avatar_index = m.group_index
    avatar_name = avatar_index ? Avatars.names[avatar_index] : ''

    group_id = params[:group_id]
    if group_id != ''
      group_events = groups[group_id].events
      prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, group_events)
    else
      prev_avatar_id,next_avatar_id = '',''
    end

    result = {
                    version: version,
                         id: id,
               prevAvatarId: prev_avatar_id,
               nextAvatarId: next_avatar_id,
                    groupId: group_id,
                avatarIndex: avatar_index,
                 avatarName: avatar_name,
                   wasIndex: was_index,
                   nowIndex: now_index,
                     events: events.map{ |event| to_json(event) },
                      diffs: view,
	      idsAndSectionCounts: pruned(view),
          currentFilenameId: pick_file_id(view, current_filename, exts)
	  }
    render json:result
  end

  private

  include DiffView
  include PrevNextAvatarIdsHelper
  include ReviewFilePicker

  def current_filename
    params[:filename]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def pruned(array)
    array.map { |hash| {
      :id            => hash[:id],
      :section_count => hash[:section_count]
    }}
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def to_json(light)
    {
      'index'     => light.index,
      'time'      => light.time,
      'predicted' => light.predicted,
      'colour'    => light.colour,
      'revert'    => light.revert
    }
  end

end
