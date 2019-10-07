
class TipperController < ApplicationController

  include TrafficLightTipHelper

  def traffic_light_tip2
    avatar_index = params[:avatar_index]
    was_index = params[:was_index].to_i
    now_index = params[:now_index].to_i
    events,was_files,now_files = kata.tipper_info(was_index, now_index)
    diff = differ.diff(id, was_files, now_files)
    html = traffic_light_tip_html2(diff, avatar_index, events, was_index, now_index)
    render json: { html:html }
  end

  def traffic_light_tip
    diff = differ.diff(id, was_files, now_files)
    render json: {
      html: traffic_light_tip_html(diff, kata.events, was_index, now_index)
    }
  end

end
