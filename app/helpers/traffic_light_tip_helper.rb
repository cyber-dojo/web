
module TrafficLightTipHelper # mix-in

  def traffic_light_tip_html(diffs, tags, avatar_name, was_tag, now_tag)
    was_tag = was_tag.to_i
    now_tag = now_tag.to_i

    tip = '<table><tr>'
    tip += td(traffic_light_img(tags, was_tag))  # rag
    tip += td(tag_html(was_tag))                 # 13
    tip += td(right_arrow)                       # ->
    tip += td(traffic_light_img(tags, now_tag))  # rag
    tip += td(tag_html(now_tag))                 # 14
    unless avatar_name == ''
      tip += td(avatar_img(avatar_name))           # panda
    end
    tip += '</tr></table>'

    tip += '<table>'
    diffs.each do |filename, diff|
      added   = diff.count { |line| line['type'] == 'added'   }
      deleted = diff.count { |line| line['type'] == 'deleted' }
      if filename != 'output' && (added + deleted != 0)
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

  def tag_html(tag_number)
    "<span class='traffic-light-diff-tip-tag'>#{tag_number}</span>"
  end

  def traffic_light_img(tags, tag_number)
    return '' if tag_number == 0
    colour = tag_colour(tags, tag_number)
    "<img src='/images/bulb_#{colour}.png' class='traffic-light-diff-tip-traffic-light-image'>"
  end

  def tag_colour(tags, tag_number)
    tags[tag_number].colour
  end

  def right_arrow
    "<div class='right-arrow'>&rarr;</div>"
  end

  def avatar_img(avatar)
    "<img src='/images/avatars/#{avatar}.jpg' class='traffic-light-diff-tip-avatar-image'>"
  end

  def diff_count(name, count)
    "<div class='traffic-light-diff-tip-line-count-#{name} some button'>#{count}</div>"
  end

  def td(text)
    '<td>' + text + '</td>'
  end

end
