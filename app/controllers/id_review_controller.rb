
class IdReviewController < ApplicationController

  def show
    @title = 'review'
  end

  def drop_down
    @id = params['id'] = katas.completed(id.upcase)
    json = { exists: kata.exists? }
    if json[:exists]
      json[:empty] = kata.avatars.started.count == 0
    end
    render json:json
  end

end
