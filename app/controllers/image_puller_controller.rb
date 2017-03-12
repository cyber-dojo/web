
class ImagePullerController < ApplicationController

  def pulled?
    begin
      result = puller.pulled?(image_name, id)
    rescue Exception => error
      #puts error.message
      result = false
    end
    render json: { result:result }
  end

  def pull
    begin
      result = puller.pull(image_name, id)
    rescue Exception => error
      #puts error.message
      result = false
    end
    render json: { result:result }
  end

end
