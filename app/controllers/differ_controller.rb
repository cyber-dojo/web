require_relative '../helpers/prev_next_avatar_ids_helper'

class DifferController < ApplicationController

  def diff
    id = params[:id]
    manifest,events = kata.diff_info

    m = Manifest.new(manifest)
    avatar_index = m.group_index
    group_id = params[:group_id]
    if group_id != ''
      group_events = groups[group_id].events
      prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, group_events)
    else
      prev_avatar_id,next_avatar_id = '',''
    end

    result = {
                         id: id,
                   wasIndex: was_index,
                   nowIndex: now_index,

                     events: events.map{ |event| to_json(event) },

                    groupId: group_id,
                avatarIndex: avatar_index.to_s, # nil -> ""
               prevAvatarId: prev_avatar_id,
               nextAvatarId: next_avatar_id
	  }
    render json:result
  end

  private

  include PrevNextAvatarIdsHelper

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
