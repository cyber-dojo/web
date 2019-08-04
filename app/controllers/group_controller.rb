
# shows button-choices when you select
# [we're in a group]
# from the home page

class GroupController < ApplicationController

  def show
    @title = 'group'
    @id = id
    @avatar_names = avatars.names
  end

end
