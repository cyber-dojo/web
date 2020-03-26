
class ShaController < ApplicationController

  def index
    @names = %w(
      creator custom-chooser exercises-chooser languages-chooser
      custom-start-points exercises-start-points languages-start-points
      avatars differ runner saver
    )
    @web_sha = ENV['SHA']
  end

end
