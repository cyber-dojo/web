
class DojoController < ApplicationController

  def index
    @title = 'home'
    @id = id
    @message = ENV['MESSAGE']
  end

  def individual
    @id = id
  end

  def team
    @id = id
  end

end
