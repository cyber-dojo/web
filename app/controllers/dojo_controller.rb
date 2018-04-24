
class DojoController < ApplicationController

  def index
    @title = 'home'
    @id = id
    @message = ENV['MESSAGE']
    @shuffled_avatar_names = Avatars.names.shuffle
    @pies_filename = %w( Coimbatore Bray Mullingar ).shuffle[0]
  end

end
