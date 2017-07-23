
module PieChartHelper # mix-in

  module_function

  def pie_chart(lights, avatar_name)
    # used in dashboard view
    pie_chart_from_counts({
            red: count(lights, :red),
          amber: count(lights, :amber),
          green: count(lights, :green),
      timed_out: count(lights, :timed_out)
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

  def count(lights, colour)
    lights.count { |light| light['colour'] == colour.to_s }
  end

end
