
class ReverterController < ApplicationController

  def revert
    render json: {
      visibleFiles: kata.tags[tag].files
    }
  end

end
