# frozen_string_literal: true

module TrafficLightHelper # mix-in

  module_function

  # The data-id, data-index properties are used to create
  # click handlers that open a diff.
  # The data-tip property is used to create a hover-tip.
  #   see setupHoverTips()
  #   in app/asserts/javascripts/cyber-dojo_hover_tips.js

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def diff_traffic_light(light, avatar_index, number)
    # [1] needed in app/views/kata/edit to count
    # the number of red/amber/green traffic-lights
    [ "<div class='diff-traffic-light'",
        " data-id='#{light.kata.id}'",
        " data-index='#{light.index}'",
        " data-number='#{number}'",
        " data-avatar-index='#{avatar_index}'",
        " data-colour='#{light.colour}'>", # [1]
        traffic_light_image(light),
      '</div>'
    ].join
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def traffic_light_count(lights)
    "<div class='traffic-light-count-wrapper'>" +
      "<div class='traffic-light-count #{lights[-1].colour}'" +
          " data-tip='traffic_light_count'" +
          " data-red-count='#{colour_count(lights, :red)}'" +
          " data-amber-count='#{colour_count(lights, :amber)}'" +
          " data-green-count='#{colour_count(lights, :green)}'" +
          " data-timed-out-count='#{colour_count(lights, :timed_out)}'>" +
        lights.count.to_s +
      '</div>' +
    '</div>'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def colour_count(traffic_lights, colour)
     traffic_lights.count { |light| light.colour == colour }
  end

  def traffic_light_image(light)
    colour = light.colour
    predicted = rag?(colour) ? "_predicted_#{light.predicted}" : ''
    "<img src='/traffic-light/image/#{colour}#{predicted}.png'" +
       " alt='#{light.colour} traffic-light'/>"
  end

  def rag?(colour)
    %w( red amber green ).include?(colour.to_s)
  end

end
