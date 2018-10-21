
class IdReviewController < ApplicationController

  def drop_down
    gid = porter.port(id)
    group = groups[gid]
    json = { exists:group.exists? }
    if json[:exists]
      json[:id] = gid
    end
    render json:json
  end

end
