
class ImagePullerController < ApplicationController

  def pulled?
    begin
      result = runner.pulled?(image_name, id)
    rescue Exception => error
      result = false
    end
    render json: { result:result }
  end

  def pull
    begin
      result = runner.pull(image_name, id)
    rescue Exception => error
      result = false
    end
    render json: { result:result }
  end

end
