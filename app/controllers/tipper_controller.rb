
class TipperController < ApplicationController

  include TipHelper

  def traffic_light_tip
    diff = differ.diff(kata.id, avatar.name, was_tag, now_tag)
    render json: {
      html: traffic_light_tip_html(diff, avatar, was_tag, now_tag)
    }
  end

end
