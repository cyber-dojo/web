
module TrafficLightTipHelper # mix-in

  def traffic_light_tip_html(diffs, events, was_index, now_index)
    tip = '<table><tr>'
    tip += td(traffic_light_img(events, was_index))  # red/amber/green
    tip += td(tag_html(was_index))                 # 13
    tip += td(right_arrow)                       # ->
    tip += td(traffic_light_img(events, now_index))  # red/amber/green
    tip += td(tag_html(now_index))                 # 14

    avatar_name = events[was_index].kata.avatar_name
    unless avatar_name == ''
      tip += td(avatar_img(avatar_name))         # panda
    end
    tip += '</tr></table>'

    tip += '<table>'
    diffs.each do |filename, diff|
      added   = diff.count { |line| line['type'] == 'added'   }
      deleted = diff.count { |line| line['type'] == 'deleted' }
      if !output?(filename) && (added + deleted != 0)
        tip += '<tr>'
        tip += td(diff_count('deleted', deleted))
        tip += td(diff_count('added', added))
        tip += td('&nbsp;' + filename)
        tip += '</tr>'
      end
    end
    tip += '</table>'
  end

  module_function

  def output?(filename)
    %w( stdout stderr status ).include?(filename)
  end

  def tag_html(index)
    "<span class='traffic-light-diff-tip-tag'>#{index}</span>"
  end

  def traffic_light_img(events, index)
    return '' if index == 0
    colour = tag_colour(events, index)
    "<img src='/images/bulb_#{colour}.png' class='traffic-light-diff-tip-traffic-light-image'>"
  end

  def tag_colour(events, index)
    events[index].colour
  end

  def right_arrow
    "<div class='right-arrow'>&rarr;</div>"
  end

  def avatar_img(name)
    "<img src='/images/avatars/#{name}.jpg' class='traffic-light-diff-tip-avatar-image'>"
  end

  def diff_count(name, count)
    "<div class='traffic-light-diff-tip-line-count-#{name} some button'>#{count}</div>"
  end

  def td(text)
    "<td>#{text}</td>"
  end

end
