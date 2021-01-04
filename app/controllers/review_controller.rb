
class ReviewController < ApplicationController

  def show
    @env = ENV    
    @id = id
    @title = "review:#{id}"
    @manifest = model.kata_manifest(id)
  end

  private

  def id
    params[:id]
  end

end
