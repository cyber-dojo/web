
# Gates a full test run. The whole suite runs in one process, so there is a
# single test.log and a single coverage report to read.

# The directory run.sh wrote the log and the coverage report to.
def coverage_dir
  ENV.fetch('COVERAGE_DIR')
end

# Rounds to 2 decimal places, as a string, eg 48.5 -> '48.50'
def f2(value)
  result = ('%.2f' % value).to_s
  result += '0' if result.end_with?('.0')
  result
end

#- - - - - - - - - - - - - - - - - - - - -

# Minitest's own summary lines, pulled out of the test log.
def test_stats
  log = IO.read("#{coverage_dir}/test.log")
  number = '([\.|\d]+)'
  stats = {}

  finished_pattern = "Finished in #{number}s, #{number} runs/s, #{number} assertions/s"
  m = log.match(Regexp.new(finished_pattern))
  stats[:time] = f2(m[1])

  summary_pattern = %w(runs assertions failures errors skips).map{ |s| "#{number} #{s}" }.join(', ')
  m = log.match(Regexp.new(summary_pattern))
  stats[:test_count]      = m[1].to_i
  stats[:assertion_count] = m[2].to_i
  stats[:failure_count]   = m[3].to_i
  stats[:error_count]     = m[4].to_i
  stats[:skip_count]      = m[5].to_i

  stats
end

#- - - - - - - - - - - - - - - - - - - - -

# The covered percentage, and the number of files, of one SimpleCov group,
# read off the generated report. Returns [percent, file_count].
def group_coverage(group)
  html = IO.read("#{coverage_dir}/index.html")
  # guard against invalid byte sequence
  html = html.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
  html = html.encode('UTF-8', 'UTF-16')

  percent_pattern = /<div class=\"file_list_container\" id=\"#{group}\">
\s*<h2>\s*<span class=\"group_name\">#{group}<\/span>
\s*\(<span class=\"covered_percent\">\s*<span class=\"\w+\">\s*([\d\.]*)\%/m

  files_pattern = /<div class=\"file_list_container\" id=\"#{group}\">
.*?<b>(\d+)<\/b> files in total/m

  [ html.match(percent_pattern)[1].to_f, html.match(files_pattern)[1].to_i ]
end

#- - - - - - - - - - - - - - - - - - - - -

# Every condition a full run must meet, as [description, pass?, actual].
def criteria(stats, percent, file_count)
  [
    [ 'failures == 0',           stats[:failure_count] == 0, stats[:failure_count] ],
    [ 'errors == 0',             stats[:error_count]   == 0, stats[:error_count]   ],
    [ 'skips == 0',              stats[:skip_count]    == 0, stats[:skip_count]    ],
    # Wall-clock for the whole suite in one process, which sits around 50s and
    # varies by a second or so between runs. The limit leaves room for that.
    [ 'secs < 60',               stats[:time].to_f < 60,     stats[:time]          ],
    [ 'code covers >= 1 file',   file_count >= 1,            file_count            ],
    [ 'code coverage >= 100',    percent >= 100,             f2(percent)           ],
  ]
end

# Prints the run's numbers, then DONE or the conditions that failed.
def print_summary(stats, percent, file_count)
  puts
  puts "tests      : #{stats[:test_count]}"
  puts "assertions : #{stats[:assertion_count]}"
  puts "failures   : #{stats[:failure_count]}"
  puts "errors     : #{stats[:error_count]}"
  puts "skips      : #{stats[:skip_count]}"
  puts "secs       : #{stats[:time]}"
  puts "code files : #{file_count}"
  puts "coverage   : #{f2(percent)}%"
  puts

  failed = criteria(stats, percent, file_count).reject { |criterion| criterion[1] }
  if failed.empty?
    puts 'DONE'
  else
    puts '!DONE'
    failed.each { |description,_,actual| puts "FAILED: #{description} (actual #{actual})" }
  end
  failed.empty?
end

#- - - - - - - - - - - - - - - - - - - - -

stats = test_stats
percent, file_count = group_coverage('code')
exit print_summary(stats, percent, file_count) ? 0 : 1
