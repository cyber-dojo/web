# frozen_string_literal: true

module TrafficLightImagePathHelper # mix-in

  def traffic_light_image_path(light)
    "/images/traffic-light/#{light.colour}.png"
  end

end
