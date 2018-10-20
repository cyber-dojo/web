
class IdReviewController < ApplicationController

  def drop_down
    gid = porter.port(id)
    exists = saver.group_exists?(gid)
    json = { exists:exists }
    if json[:exists]
      json[:id] = gid
    end
    render json:json
  end

end
