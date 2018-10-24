
class ReverterController < ApplicationController

  def revert
    render json: {
      visibleFiles: kata.events[tag].files
    }
  end

end
