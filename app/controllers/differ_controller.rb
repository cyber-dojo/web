require_relative '../helpers/prev_next_avatar_ids_helper'

class DifferController < ApplicationController

  def diff
    id = params[:id]
    group_id = params[:group_id]

    joined = model.group_joined(id)
    prev_id,index,next_id = prev_next_avatar_ids(id, joined)

    result = {
                         id: id,
                   wasIndex: was_index.to_i,
                   nowIndex: now_index.to_i,

                    groupId: group_id,
               prevAvatarId: prev_id,
               nextAvatarId: next_id,

                avatarIndex: index.to_s # nil -> ""
	  }
    render json:result
  end

  private

  include PrevNextAvatarIdsHelper

end
