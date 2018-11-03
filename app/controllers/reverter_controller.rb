
class ReverterController < ApplicationController

  def revert
    index = params[:tag].to_i
    render json: {
      visibleFiles: kata.events[index].files
    }
  end

end
