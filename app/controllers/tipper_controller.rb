
class TipperController < ApplicationController

  include TrafficLightTipHelper

  def traffic_light_tip
    diff = differ.diff(kata.id, was_tag, now_tag)
    render json: {
      html: traffic_light_tip_html(diff, kata.tags, avatar_name, was_tag, now_tag)
    }
  end

end
