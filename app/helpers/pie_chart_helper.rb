
module PieChartHelper # mix-in

  module_function

  def pie_chart(lights, avatar_name)
    pie_chart_from_counts({
            red: count(lights, :red),
          amber: count(lights, :amber),
          green: count(lights, :green),
      timed_out: count(lights, :timed_out)
    }, 34, avatar_name)
  end

  def pie_chart2(lights, avatar_name)
    # used in dashboard's view
    pie_chart_from_counts({
            red: count2(lights, :red),
          amber: count2(lights, :amber),
          green: count2(lights, :green),
      timed_out: count2(lights, :timed_out)
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
    lights.entries.count { |light|
      light.colour == colour
    }
  end

  def count2(lights, colour)
    lights.entries.count { |light|
      light['colour'] == colour.to_s
    }
  end

end
