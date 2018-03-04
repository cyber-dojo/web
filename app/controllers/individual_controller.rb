
class IndividualController < ApplicationController

  def show
    @title = 'individual'
    @id = id
    @avatar = Avatars.names.shuffle[0]
  end

end
