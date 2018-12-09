
class IdReviewController < ApplicationController

  def drop_down
    group = groups[id] # [porter.port(id)]
    json = { exists:group.exists? }
    if json[:exists]
      json[:id] = group.id
    end
    render json:json
  end

end
