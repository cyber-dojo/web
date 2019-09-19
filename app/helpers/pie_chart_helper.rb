# frozen_string_literal: true

module PieChartHelper # mix-in

  module_function

  def pie_chart(lights)
    # used in dashboard view
    key = lights[-1].kata.avatar_name
    pie_chart_from_counts({
            red: colour_count(lights, :red),
          amber: colour_count(lights, :amber),
          green: colour_count(lights, :green),
      timed_out: colour_count(lights, :timed_out)
    }, key)
  end

  def pie_chart_from_counts(counts, key)
    size = 32
     '<div ' +
       " class='pie-chart-wrapper'" +
       " width='#{size}px'" +
       " height='#{size}px'>" +
       '<canvas' +
          " class='pie'" +
          " data-red-count='#{counts[:red]}'" +
          " data-amber-count='#{counts[:amber]}'" +
          " data-green-count='#{counts[:green]}'" +
          " data-timed-out-count='#{counts[:timed_out]}'" +
          " data-key='#{key}'" +
          " width='#{size}px'" +
          " height='#{size}px'>" +
        '</canvas>' +
      '</div>';
  end

  def colour_count(lights, colour)
    lights.count { |light| light.colour == colour }
  end

end
