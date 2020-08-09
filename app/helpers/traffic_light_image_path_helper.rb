# frozen_string_literal: true

module TrafficLightImagePathHelper # mix-in

  def traffic_light_image_path(light)
    "/traffic-light/image/#{light.colour}#{imgSuffix(light)}.png"
  end

  module_function

  def imgSuffix(light)
    if !rag?(light.colour)
      ''
    elsif light.revert
      '_revert'
    else
      predicted = light.predicted || 'none'
      "_predicted_#{predicted}"
    end
  end

  def rag?(colour)
    %w( red amber green ).include?(colour.to_s)
  end

end
