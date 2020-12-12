
class ReviewController < ApplicationController

  def show
    @id = kata.id
    @title = "review:#{kata.id}"
    @manifest = model.kata_manifest(@id)
  end

end
