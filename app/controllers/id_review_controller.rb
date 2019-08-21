
class IdReviewController < ApplicationController

  def drop_down
    json = { exists:group.exists? }
    if json[:exists]
      json[:id] = group.id
    end
    render json:json
  end

end
