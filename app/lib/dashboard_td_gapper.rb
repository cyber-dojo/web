# frozen_string_literal: true

class DashboardTdGapper

  def initialize(start, seconds_per_td, max_seconds_uncollapsed)
    @start = start
    @seconds_per_td = seconds_per_td
    @max_seconds_uncollapsed = max_seconds_uncollapsed
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def fully_gapped(all_lights, now)
    s = stats(all_lights, now)
    vertical_bleed(s)
    collapsed_table(s[:td_nos]).each do |td, gi|
      count = gi[1]
      s[:katas].each do |_id, td_map|
        count.times { |n| td_map[td + n + 1] = [] } if gi[0] == :dont_collapse
        td_map[td + 1] = { collapsed: count } if gi[0] == :collapse
      end
    end
    # eg
    # s[:katas] == {
    #   'de535Z' => {
    #       0 => [],
    #       5 => [R,G],
    #       7 => [],
    #      11 => [G,R],
    #      99 => []
    #   },
    #   '3s1BqT' => {
    #       0 => [],
    #       5 => [A],
    #       7 => [G,A],
    #      11 => [],
    #      99 => []
    #   }
    # }
    #
    # eg
    # collapsed_table == {
    #    0 => [ :collapse,       4 ],  #  4 == ( 5- 0) - 1
    #    5 => [ :dont_collapse,  1 ],  #  1 == ( 7- 5) - 1
    #    7 => [ :dont_collapse,  3 ],  #  3 == (11- 7) - 1
    #   11 => [ :collapse,      87 ]   # 87 == (99-11) - 1
    # }
    # so td_map[] additions are
    #    0: 0+1    1 => { collapsed:4 }
    #    5: 5+0+1  6 => []
    #    7: 7+0+1  8 => []
    #    7: 7+1+1  9 => []
    #    7: 7+2+1 10 => []
    #   11: 11+1  12 => { collapsed:87 }
    #
    # so td_map becomes
    #          0   1        5      6   7     8   9   10   11    12
    # 'de535Z' []  {c'd:4}  [R,G]  []  []    []  []  []   [G,R] {c'd:87},
    # '3s1BqT' []  {c'd:4}  [A]    []  [G,A] []  []  []   []    {c'd:87}

    strip(s[:katas])
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def time_ticks(gapped)
    return {} if gapped == {}
    ticks = {}
    kata_id = gapped.keys.sample
    gapped[kata_id].each do |td,content|
      if content.is_a?(Array)
        ticks[td] = (td+1) * @seconds_per_td
      else
        ticks[td] = content # { collapsed:N }
      end
    end
    ticks
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def stats(all_lights, now)
    obj = { katas: {}, td_nos: [0, n(now)] }
    # eg td_nos: [0,99]
    all_lights.each do |kata_id, lights|
      an = obj[:katas][kata_id] = {}
      lights.each do |light|
        tdn = number(light)
        an[tdn] ||= []
        an[tdn] << light
        obj[:td_nos] << tdn
      end
    end
    obj[:td_nos].sort!.uniq!
    obj
    # eg katas: {
    #     'de535Z' => { 5=>[R,G], 11=[G,R] },
    #     '3s1BqT' => { 5=>[A],   7=>[G,A] }
    #   }
    # eg td_nos: [ 0,5,7,11,99 ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def vertical_bleed(s)
    s[:td_nos].each do |n|
      s[:katas].each do |_kata_id, td_map|
        td_map[n] ||= []
      end
    end
    # eg katas: {
    #     'de535Z' => { 0=>[], 5=>[R,G], 7=>[],    11=[G,R], 99=>[] },
    #     '3s1BqT' => { 0=>[], 5=>[A],   7=>[G,A], 11=>[],   99=>[] }
    #   }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def collapsed_table(td_nos)
    max_uncollapsed_tds = @max_seconds_uncollapsed / @seconds_per_td
    obj = {}
    td_nos.each_cons(2) do |p|
      diff = p[1] - p[0]
      key = diff < max_uncollapsed_tds ? :dont_collapse : :collapse
      obj[p[0]] = [key, diff - 1]
    end
    obj
    # eg td_nos: [ 0,5,7,8,11,99 ]
    # eg max_uncollapsed_tds = 240/60 == 4
    # each_cons(2)
    #   p[0]  p[1]  diff
    #   - - - - - - - -
    #   0     5     5       5<4==false  :collapse
    #   5     7     2       2<4==true   :dont_collapse
    #   7     8     1       1<4==true   :dont_collapse
    #   8    11     3       3<4==true   :dont_collapse
    #   11   99    88      88<4==false  :collapse
    #
    # obj: {
    #    0 => [ :collapse,       4 ],  # ( 5- 0)-1
    #    5 => [ :dont_collapse,  1 ],  # ( 7- 5)-1
    #    7 => [ :dont_collapse,  0 ],  # ( 8- 7)-0
    #    8 => [ :dont_collapse,  2 ],  # (11- 8)-1
    #   11 => [ :collapse,      87 ]   # (99-11)-1
    # }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def strip(gapped)
    # remove lightless columns from both ends
    return gapped if gapped == {}

        empty_column = ->(td) { gapped.all? { |_, h| h[td] == [] } }
    collapsed_column = ->(td) { gapped.all? { |_, h| h[td].is_a?(Hash) } }
    lightless_column = ->(td) { empty_column.call(td) || collapsed_column.call(td) }
       delete_column = ->(td) { gapped.each { |_, h| h.delete(td) } }

    kata_id = gapped.keys[0]
    gapped[kata_id].keys.sort.reverse_each do |td|
      if lightless_column.call(td)
        delete_column.call(td)
      else
        break
      end
    end
    gapped[kata_id].keys.sort.each do |td|
      if lightless_column.call(td)
        delete_column.call(td)
      else
        break
      end
    end
    gapped
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def number(light)
    n(light.time)
  end

  def n(now)
    ordinal(Time.mktime(*now))
  end

  def ordinal(o)
    ((o - @start) / @seconds_per_td).to_i
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# I want the |horizontal| spacing between dashboard traffic
# lights to be proportional to the time difference between
# them. I also want traffic-lights from different avatars
# but occurring at the same moment in time to align
# -vertically -
#
# These two requirements are somewhat in tension with each
# other. The best solution I can think of is to split each
# avatar's traffic light tr into the same number of td's by
# making each td represent a period of time, say 60 seconds.
#
# The start time will be the start time of the dojo.
# The end time will be the current time.
#
# If there's lots of empty td's in a row (for all avatars)
# I collapse them all into a single td (for all avatars).
# This ensures that the display never shows just empty td's
# except if the dojo has just started.

# collapsed_table
# ---------------
# Suppose I have hippo with lights for td's numbered
# 5 and 15 and that the time this gap (from 5 to 15, viz
# 9 td's) represents is large enough to be collapsed.
# Does this mean the hippo's tr gets 9 empty td's between
# the td#5 and the td#15?
# The answer is it depends on the _other_ avatars.
# The td's have to align vertically.
# For example if the lion has a td at 11 then
# this effectively means that for the hippo its 5-15 has
# to be considered as 5-11-15 and the gaps are really
#  5-11 (5 td gaps) and
# 11-15 (3 td gaps).
# This is where the :td_nos array comes in.
# It is an array of all td numbers for a dojo across all
# avatars.
# Suppose the :td_nos array is [1,5,11,13,15,16,18,23]
# This means that the hippo has to treat its 5-15 gap as
# 5-11-13-15 so the gaps are really
#  5-11 (5 td gaps),
# 11-13 (1 td gap) and
# 13-15 (1 td gap).
# Note that the hippo doesn't have a light at either
# 13 or 15 but that doesn't matter, we can't collapse "across"
# or "through" these because I want vertical consistency.

# Now, suppose a dojo runs over two days, there would be a
# long period of time at night when no traffic lights would
# get added. Thus the :td_nos array is likely to have large
# gaps, eg [....450,2236,2237,...]
# at 20 seconds per gap the difference between 450 and 2236
# is 1786 and 1786*20 == 35,720 seconds == 9 hours 55 mins
# 20 secs. We would not want this displayed as 1786 empty
# td's! Thus there is a max_seconds_uncollapsed parameter.
# If the time difference between two consecutive entries in
# the :td_nos array is greater than max_seconds_uncollapsed
# the display will not show one td for each gap but will
# collapse the entire gap down to one td.
# A collapsed td is shown with a ... in it.
