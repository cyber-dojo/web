
class IdReviewController < ApplicationController

  def drop_down
    gid = porter.port(id)
    exists = groups[gid].exists?
    json = { exists:exists }
    if json[:exists]
      json[:id] = gid
    end
    render json:json
  end

end
