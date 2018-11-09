
class DojoController < ApplicationController

  def index
    @title = 'home'
    @id = id
    @message = ENV['MESSAGE']
    @pies_filename = %w( Coimbatore Bray Mullingar ).shuffle[0]
  end

end
