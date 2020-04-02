# frozen_string_literal: true

module TrafficLightTipHelper # mix-in

  def traffic_light_tip_html(diffs, avatar_index, events, now_index)
    tip = '<table><tr>'
    unless avatar_index.nil? || avatar_index === ''
      tip += td(avatar_img(avatar_index))           # panda
    end
    tip += td(traffic_light_img(events, now_index)) # red/amber/green
    tip += td(tag_html(now_index))                  # 14
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
    return '' if index === 0
    light = events[index]
    "<img src='/traffic-light/image/#{light.colour}_predicted_#{light.predicted}.png'" +
      " class='traffic-light-diff-tip-traffic-light-image'>"
  end

  def avatar_img(index)
    "<img src='/avatar/image/#{index}' class='traffic-light-diff-tip-avatar-image'>"
  end

  def diff_count(name, count)
    "<div class='traffic-light-diff-tip-line-count-#{name} some button'>#{count}</div>"
  end

  def td(text)
    "<td>#{text}</td>"
  end

end
