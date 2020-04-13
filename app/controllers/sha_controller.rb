
class ShaController < ApplicationController

  def index
    @names = %w(
      custom-chooser exercises-chooser languages-chooser
      custom-start-points exercises-start-points languages-start-points
      avatars creator differ repler runner saver
    )
    @web_sha = ENV['SHA']
  end

end
