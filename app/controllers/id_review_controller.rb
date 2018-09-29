
class IdReviewController < ApplicationController

  def drop_down
    @id = grouper.id_completed(id)
    json = { exists: @id != '' }
    if json[:exists]
      json[:id] = @id
    end
    render json:json
  end

end
