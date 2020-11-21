require_relative '../helpers/prev_next_avatar_ids_helper'

class DifferController < ApplicationController

  def diff
    id = params[:id]
    joined = model.group_joined(id)
    prev_id,index,next_id = prev_next_avatar_ids(id, joined)
    result = {
                         id: id,
                   wasIndex: was_index.to_i,
                   nowIndex: now_index.to_i,

               prevAvatarId: prev_id,
               avatarIndex: index.to_s, # nil -> ""
               nextAvatarId: next_id
	  }
    render json:result
  end

  private

  include PrevNextAvatarIdsHelper

end
