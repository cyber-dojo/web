require_relative '../helpers/prev_next_avatar_ids_helper'

class DifferController < ApplicationController

  def diff
    version = params[:version].to_i
    id = params[:id]
    manifest,events = kata.diff_info

    diff = differ.diff_lines(id, was_index, now_index)
    view = diff_view(diff)

    m = Manifest.new(manifest)
    exts = m.filename_extension
    avatar_index = m.group_index

    group_id = params[:group_id]
    if group_id != ''
      group_events = groups[group_id].events
      prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, group_events)
    else
      prev_avatar_id,next_avatar_id = '',''
    end

    current_filename_id = pick_file_id(view, current_filename, exts)

    result = {
                    version: version,

                         id: id,
                   wasIndex: was_index,
                   nowIndex: now_index,
                     events: events.map{ |event| to_json(event) },
                      diffs: view,

                    groupId: group_id,
                avatarIndex: avatar_index.to_s, # nil -> ""
               prevAvatarId: prev_avatar_id,
               nextAvatarId: next_avatar_id,

          currentFilenameId: current_filename_id
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
