
class IdReviewController < ApplicationController

  def drop_down
    group = groups[porter.port(id)]
    json = { exists:group.exists? }
    if json[:exists]
      json[:id] = group.id
    end
    render json:json
  end

end
