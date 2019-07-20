
class TipperController < ApplicationController

  include TrafficLightTipHelper

  def traffic_light_tip
    diff = differ.diff(id, was_files, now_files)
    render json: {
      html: traffic_light_tip_html(diff, kata.events, was_index, now_index)
    }
  end

end
