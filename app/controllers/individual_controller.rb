
# shows button-choices when you select
# [i'm on my own]
# from the home page

class IndividualController < ApplicationController

  def show
    @title = 'individual'
    @id = id
    @avatar = Avatars.names.shuffle[0]
  end

end
