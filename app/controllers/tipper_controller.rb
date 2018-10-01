
class TipperController < ApplicationController

  include TrafficLightTipHelper

  def traffic_light_tip
    diff = differ.diff(kata.id, was_tag, now_tag)
    render json: {
      html: traffic_light_tip_html(diff, avatar_name, kata.tags, was_tag, now_tag)
    }
  end

end
