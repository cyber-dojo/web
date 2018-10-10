
class IdReviewController < ApplicationController

  def drop_down
    @id = id
    exists = grouper.group_exists?(id)
    json = { exists:exists }
    if json[:exists]
      json[:id] = @id
    end
    render json:json
  end

end
