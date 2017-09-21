
class DojoController < ApplicationController

  def index
    @title = 'home'
    @id = id
    @message = ENV['MESSAGE']
  end

end
