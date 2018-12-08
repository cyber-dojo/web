
class ReverterController < ApplicationController

  def revert
    render json: {
      visibleFiles: files_for(index)
    }
  end

end
