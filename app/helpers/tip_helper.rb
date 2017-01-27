
module TipHelper # mix-in

  def traffic_light_tip_html(diffs, avatar, was_tag, now_tag)
    was_tag = was_tag.to_i
    now_tag = now_tag.to_i
    lights = avatar.lights

    tip = '<table><tr>'
    tip += td(traffic_light_img(lights, was_tag))  # rag
    tip += td(colour_tag(lights, was_tag))         # 13
    tip += td(right_arrow)                         # ->
    tip += td(traffic_light_img(lights, now_tag))  # rag
    tip += td(colour_tag(lights, now_tag))         # 14
    tip += td(avatar_img(avatar.name))             # panda
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

  def colour_tag(lights, tag)
    colour = (tag == 0) ? 'none' : lights[tag-1].colour
    "<span class='traffic-light-diff-tip-tag #{colour}'>#{tag}</span>"
  end

  def traffic_light_img(lights, tag)
    return '' if tag == 0
    colour = lights[tag-1].colour
    "<img src='/images/bulb_#{colour}.png' class='traffic-light-diff-tip-traffic-light-image'>"
  end

  def right_arrow
    '<div>&rarr;</div>'
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
