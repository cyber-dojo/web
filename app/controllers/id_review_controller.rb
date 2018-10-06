
class IdReviewController < ApplicationController

  def drop_down
    @id = id
    exists = grouper.exists?(id)
    json = { exists:exists }
    if json[:exists]
      json[:id] = @id
    end
    render json:json
  end

end
