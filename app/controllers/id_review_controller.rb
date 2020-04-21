
class IdReviewController < ApplicationController

  def review
    json = { exists:group.exists? }
    if json[:exists]
      json[:id] = group.id
    end
    render json:json
  end

  def drop_down # deprecated
    review
  end

end
