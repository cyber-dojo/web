
class ReviewController < ApplicationController

  def show
    @id = kata.id
    @title = "review:#{kata.id}"
    @manifest = kata.manifest
    @was_index = was_index
    @now_index = now_index
  end

end
