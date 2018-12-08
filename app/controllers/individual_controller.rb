
# shows button-choices when you select
# [i'm on my own]
# from the home page

class IndividualController < ApplicationController

  def show
    @title = 'individual'
    @id = id
  end

end
