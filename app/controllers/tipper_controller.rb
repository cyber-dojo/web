
class TipperController < ApplicationController

  include TrafficLightTipHelper

  def traffic_light_tip
    kata = katas[id]
    events = kata.events
    was_files = events[was_tag].files(:with_output)
    now_files = events[now_tag].files(:with_output)
    diff = differ.diff(was_files, now_files)
    render json: {
      html: traffic_light_tip_html(diff, events, was_tag, now_tag)
    }
  end

end
