
class IndividualController < ApplicationController

  def home
    @title = 'individual'
    @id = id
    @avatar = Avatars.names.shuffle[0]
  end

end
