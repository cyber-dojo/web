require_relative '../helpers/prev_next_avatar_ids_helper'

class DifferController < ApplicationController

  def diff
    id = params[:id]
    group_id = params[:group_id]
    manifest = kata.manifest
    avatar_index = manifest.group_index

    joined = model.group_joined(id)
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, joined)

    result = {
                         id: id,
                   wasIndex: was_index.to_i,
                   nowIndex: now_index.to_i,

                    groupId: group_id,
               prevAvatarId: prev_avatar_id,
               nextAvatarId: next_avatar_id,

                avatarIndex: avatar_index.to_s # nil -> ""
	  }
    render json:result
  end

  private

  include PrevNextAvatarIdsHelper

end
