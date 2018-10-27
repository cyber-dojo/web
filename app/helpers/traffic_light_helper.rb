
module TrafficLightHelper # mix-in

  module_function

  # The data-id, data-avatar-name, data-was-tag, data-now-tag
  # properties are used to create click handlers that open a diff-dialog
  #   see setupTrafficLightOpensHistoryDialogHandlers()
  #   in app/asserts/javascripts/cyber-dojo_show_review_url.js

  # The data-tip property is used to create a hover-tip.
  #   see setupHoverTips()
  #   in app/asserts/javascripts/cyber-dojo_hover_tips.js

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def diff_traffic_light(light)
    # [1] data-colour is needed in app/views/kata/edit to
    # count the number of red/amber/green traffic-lights
    "<div class='diff-traffic-light'" +
        " data-tip='ajax:traffic_light'" +
        " data-id='#{light.kata.id}'" +
        " data-colour='#{light.colour}'" + # [1]
        " data-tag='#{light.index}'>" +
        traffic_light_image(light.colour) +
     '</div>'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def diff_avatar_image(kata_id, avatar_name)
    "<div class='avatar-image'" +
        " data-tip='review #{avatar_name}#{apostrophe}s<br/>current code'" +
        " data-id='#{kata_id}'>" +
        avatar_image(avatar_name) +
     '</div>'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def traffic_light_count(lights)
    "<div class='traffic-light-count #{lights[-1].colour}'" +
        " data-tip='traffic_light_count'" +
        " data-avatar-name='#{lights[-1].kata.avatar_name}'" +
        " data-red-count='#{colour_count(lights, :red)}'" +
        " data-amber-count='#{colour_count(lights, :amber)}'" +
        " data-green-count='#{colour_count(lights, :green)}'" +
        " data-timed-out-count='#{colour_count(lights, :timed_out)}'>" +
      lights.count.to_s +
    '</div>'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def colour_count(traffic_lights, colour)
     traffic_lights.count { |light| light.colour == colour }
  end

  def avatar_image(avatar_name)
    "<img src='/images/avatars/#{avatar_name}.jpg'" +
        " alt='#{avatar_name}'/>"
  end

  def traffic_light_image(colour)
    "<img src='/images/bulb_#{colour}.png'" +
       " alt='#{colour} traffic-light'/>"
  end

  def apostrophe
    '&#39;'
  end

end
