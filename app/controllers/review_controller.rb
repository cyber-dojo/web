
class ReviewController < ApplicationController

  def show
    @id = kata.id
    @title = "review:#{kata.id}"
    @manifest = model.kata_manifest(@id)
    @was_index = params[:was_index].to_i
    @now_index = params[:now_index].to_i
  end

end
