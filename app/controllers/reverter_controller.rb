
class ReverterController < ApplicationController

  def revert
    render json: {
      visibleFiles: avatar.tags[tag].visible_files
    }
  end

end
