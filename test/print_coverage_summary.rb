#!/usr/bin/env ruby

def modules
   ARGV
end

def wrapper_test_log
  # duplicated in test/test_wrapper.sh
  'coverage/test.log'
end

#- - - - - - - - - - - - - - - - - - - - -

def f2(s)
  result = ("%.2f" % s).to_s
  result += '0' if result.end_with?('.0')
  result
end

def padded(width,it)
  " " * (width - it.to_s.length)
end

def print_left(width,it)
  print it.to_s + padded(width,it)
end

def print_right(width,it)
  print padded(width,it) + it.to_s
end

def indent
  16
end

def line_width
  columns.map{|_,values| values[0]}.reduce(:+) + indent
end

def print_line
  puts '- ' * ((line_width+1)/2)
end

#- - - - - - - - - - - - - - - - - - - - -

def column_names
  [
    :test_count,
    :assertion_count,
    :failure_count,
    :error_count,
    :skip_count,
    :time,
    :tests_per_sec,
    :assertions_per_sec,
    :coverage
  ]
end

#- - - - - - - - - - - - - - - - - - - - -

def columns
  names = column_names
  n = -1
  { #              [0]=indent, [1]=abbreviated, [2]=unabbreviated
    names[n += 1] => [  5, 't',      'number of tests'       ],
    names[n += 1] => [  7, 'a',      'number of assertions'  ],
    names[n += 1] => [  3, 'f',      'number of failures'    ],
    names[n += 1] => [  3, 'e',      'number of errors'      ],
    names[n += 1] => [  3, 's',      'number of skips'       ],
    names[n += 1] => [  7, 'secs',   'time in seconds'       ],
    names[n += 1] => [  7, 't/sec',  'tests per second'      ],
    names[n += 1] => [  7, 'a/sec',  'assertions per second' ],
    names[n += 1] => [  9, 'cov',    'coverage %'            ],
  }
end

#- - - - - - - - - - - - - - - - - - - - -

def gather_stats
  stats = {}
  number = '([\.|\d]+)'
  modules.each do |module_name|

    log = `cat #{module_name}/#{wrapper_test_log}`
    `rm #{module_name}/#{wrapper_test_log}`
    h = stats[module_name] = {}

    finished_pattern = "Finished in #{number}s, #{number} runs/s, #{number} assertions/s"
    m = log.match(Regexp.new(finished_pattern))
    h[:time]               = f2(m[1])
    h[:tests_per_sec]      = m[2].to_i
    h[:assertions_per_sec] = m[3].to_i

    summary_pattern = %w(runs assertions failures errors skips).map{ |s| "#{number} #{s}" }.join(', ')
    m = log.match(Regexp.new(summary_pattern))
    h[:test_count]      = m[1].to_i
    h[:assertion_count] = m[2].to_i
    h[:failure_count]   = m[3].to_i
    h[:error_count]     = m[4].to_i
    h[:skip_count]      = m[5].to_i

    coverage_pattern = "Coverage of ([^\=]*) = #{number}%"
    m = log.match(Regexp.new(coverage_pattern))
    h[:coverage] = f2(m[2])
  end
  stats
end

#- - - - - - - - - - - - - - - - - - - - -

def print_column_keys
  column_names.each do |name|
    puts columns[name][1] + ' == ' + columns[name][2]
  end
end

#- - - - - - - - - - - - - - - - - - - - -

def print_heading
  print_left(indent, '')
  column_names.each { |name| print_right(columns[name][0], columns[name][1]) }
  print "\n"
end

#- - - - - - - - - - - - - - - - - - - - -

def print_stats(stats)
  modules.each do |module_name|
    h = stats[module_name]
    print_left(indent, module_name)
    column_names.each { |name| print_right(columns[name][0], stats[module_name][name]) }
    print "\n"
  end
end

#- - - - - - - - - - - - - - - - - - - - -

def gather_totals(stats)
  totals = {}
  fill = lambda { |key,value| totals[key] = value }
  stat = lambda { |key| stats.map{|_,h| h[key].to_i}.reduce(:+) }
  fill.call(name=:test_count,              test_count = stat.call(name))
  fill.call(name=:assertion_count,    assertion_count = stat.call(name))
  fill.call(name=:failure_count,                        stat.call(name))
  fill.call(name=:error_count,                          stat.call(name))
  fill.call(name=:skip_count,                           stat.call(name))
  fill.call(name=:time,                          secs = f2(stats.map { |_,h| h[name].to_f }.reduce(:+)))
  fill.call(     :tests_per_sec,      (test_count / secs.to_f).to_i)
  fill.call(     :assertions_per_sec, (assertion_count / secs.to_f).to_i)
  totals
end

def print_totals(totals)
  pr = lambda { |key| print_right(columns[key][0], totals[key]) }
  print_left(indent, 'total')
  pr.call(:test_count)
  pr.call(:assertion_count)
  pr.call(:failure_count)
  pr.call(:error_count)
  pr.call(:skip_count)
  pr.call(:time)
  pr.call(:tests_per_sec)
  pr.call(:assertions_per_sec)
end

#- - - - - - - - - - - - - - - - - - - - -

def coverage(stats, name, min = 100)
  percent = stats[name][:coverage]
  [ "#{name} coverage >= #{min}", percent.to_f >= min ]
end

#- - - - - - - - - - - - - - - - - - - - -

def gather_done(stats, totals)
  [
     [ "total failures == 0", totals[:failure_count] <= 0 ],
     [ "total errors == 0", totals[:error_count] == 0 ],
     [ "total skips == 0", totals[:skip_count] == 0],
     coverage(stats, 'app_helpers'),
     coverage(stats, 'app_lib'),
     coverage(stats, 'app_models'),
     coverage(stats, 'app_controllers'),
     [ "total secs < 60", totals[:time].to_f < 60 ],
     [ "total assertions per sec > 40", totals[:assertions_per_sec] > 40 ]
  ]
end

#- - - - - - - - - - - - - - - - - - - - -

def print_done(done)
  yes,no = done.partition { |criteria| criteria[1] }
  unless yes.empty?
    puts "DONE"
    yes.each { |criteria| puts criteria[0] }
  end
  unless no.empty?
    print "\n"
    puts "!DONE"
    no.each { |criteria| puts criteria[0] }
  end
end

#- - - - - - - - - - - - - - - - - - - - -

stats = gather_stats
print "\n"
print_column_keys
print "\n"
print_heading
print_line
print_stats(stats)
print_line
totals = gather_totals(stats)
print_totals(totals)
print "\n"
print "\n"
done = gather_done(stats, totals)
print_done(done)

exit done.all? { |criteria| criteria[1] } ? 0 : 1
