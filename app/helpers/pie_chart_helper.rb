
module PieChartHelper # mix-in

  module_function

  def pie_chart(lights, avatar_name)
    # used in dashboard view
    pie_chart_from_counts({
            red: colour_count(lights, :red),
          amber: colour_count(lights, :amber),
          green: colour_count(lights, :green),
      timed_out: colour_count(lights, :timed_out)
    }, 34, avatar_name)
  end

  def pie_chart_from_counts(counts, size, avatar_name)
     '<canvas' +
        " class='pie'" +
        " data-red-count='#{counts[:red]}'" +
        " data-amber-count='#{counts[:amber]}'" +
        " data-green-count='#{counts[:green]}'" +
        " data-timed-out-count='#{counts[:timed_out]}'" +
        " data-key='#{avatar_name}'" +
        " width='#{size}'" +
        " height='#{size}'>" +
      '</canvas>'
  end

  def colour_count(lights, colour)
    lights.count { |light| light.colour == colour }
  end

end
