
class TipperController < ApplicationController

  include TrafficLightTipHelper

  def traffic_light_tip
    avatar_index = params[:avatar_index]
    was_index = params[:was_index].to_i
    now_index = params[:now_index].to_i
    number = params[:number].to_i
    events,was_files,now_files = kata.tipper_info(was_index, now_index)
    tip_data = differ.diff_tip_data(id, was_files, now_files)
    html = traffic_light_tip_html(tip_data, avatar_index, events, now_index, number)
    render json: { html:html }
  end

end
