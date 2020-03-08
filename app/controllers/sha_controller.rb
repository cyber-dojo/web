
class ShaController < ApplicationController

  def index
    @names = %w(
      creator custom-chooser
      custom-start-points exercises-start-points languages-start-points
      avatar differ runner saver
    )
    @web_sha = ENV['SHA']
  end

end
