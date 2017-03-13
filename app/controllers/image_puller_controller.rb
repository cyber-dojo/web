
class ImagePullerController < ApplicationController

  def image_pulled?
    begin
      result = runner.image_pulled?(image_name, id)
    rescue Exception => error
      #puts error.message
      result = false
    end
    render json: { result:result }
  end

  def image_pull
    begin
      result = runner.image_pull(image_name, id)
    rescue Exception => error
      #puts error.message
      result = false
    end
    render json: { result:result }
  end

end
