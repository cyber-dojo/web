
class TipperController < ApplicationController

  include TrafficLightTipHelper

  def info(letter)
    #puts "#{letter}:#{saver.log.size}"
  end

  def traffic_light_tip2
    info('A') # 22
    was_index = params[:was_index].to_i
    now_index = params[:now_index].to_i
    info('B') # 22
    manifest,events,was_files,now_files = kata.tipper_files(was_index, now_index)
    info('C') # 23
    diff = differ.diff(id, was_files, now_files)
    info('D') # 23
    avatar_index = manifest['group_index']
    html = traffic_light_tip_html2(diff, avatar_index, events, was_index, now_index)
    info('E') # 23
    render json: { html:html }
  end

  def traffic_light_tip
    diff = differ.diff(id, was_files, now_files)
    render json: {
      html: traffic_light_tip_html(diff, kata.events, was_index, now_index)
    }
  end

end
