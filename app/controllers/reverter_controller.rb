
class ReverterController < ApplicationController

  def revert
    render json: {
      visibleFiles: kata.events[index].files
    }
  end

end
