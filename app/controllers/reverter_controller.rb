
class ReverterController < ApplicationController

  def revert
    tag = params[:tag].to_i
    render json: {
      visibleFiles: kata.events[tag].files
    }
  end

end
