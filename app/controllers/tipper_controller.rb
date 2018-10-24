
class TipperController < ApplicationController

  include TrafficLightTipHelper

  def traffic_light_tip
    kata = katas[id]
    diff = differ.diff(kata.id, was_tag, now_tag)
    render json: {
      html: traffic_light_tip_html(diff, kata.avatar_name, kata.events, was_tag, now_tag)
    }
  end

end
