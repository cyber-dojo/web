
class ReverterController < ApplicationController

  def revert
    render json: {
      visibleFiles: kata.tags[tag].visible_files
    }
  end

end
