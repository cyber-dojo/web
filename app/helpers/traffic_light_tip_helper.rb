# frozen_string_literal: true
require_relative 'traffic_light_image_path_helper'

module TrafficLightTipHelper # mix-in

  def traffic_light_tip_html(tip_data, avatar_index, events, now_index, number)
    tip = '<table>'
    tip += '<tr>'
    unless avatar_index.nil? || avatar_index === ''
      tip += td(avatar_img(avatar_index))     # eg panda
    end
    event = events[now_index]
    tip += td(tag_html(event.colour, number)) # eg 14
    tip += td(traffic_light_img(event))       # eg red-traffic-light
    tip += '</tr>'
    tip += '</table>'

    tip += '<table>'
    tip_data.each do |filename,count|
      tip += '<tr>'
      tip += td(diff_count('deleted', count['deleted']))
      tip += td(diff_count('added', count['added']))
      tip += td('&nbsp;' + filename)
      tip += '</tr>'
    end
    tip += '</table>'
  end

  module_function

  include TrafficLightImagePathHelper

  def tag_html(colour, number)
    "<span class='traffic-light-count #{colour}'>#{number}</span>"
  end

  def traffic_light_img(light)
    colour = light.colour
    if colour.to_s === ''
      ''
    else
      "<img src='#{traffic_light_image_path(light)}'" +
        " class='traffic-light-diff-tip-traffic-light-image'>"
    end
  end

  def avatar_img(index)
    "<img src='/avatars/image/#{index}'" +
      " class='traffic-light-diff-tip-avatar-image'>"
  end

  def diff_count(name, count)
    "<div class='traffic-light-diff-tip-line-count-#{name} some button'>#{count}</div>"
  end

  def td(text)
    "<td>#{text}</td>"
  end

end
