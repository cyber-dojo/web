# Uses data from two json files:
# - reports/server/test_metrics.json     generated in slim_json_reporter.rb by minitest. See id58_test_base.rb
# - reports/server/coverage_metrics.json generated in simplecov_formatter_json.rb by simplecov. See coverage.rb

require 'json'

def coloured(arg)
  red = 31
  green = 32
  colourize(arg ? green : red, arg)
end

def colourize(code, word)
  "\e[#{code}m #{word} \e[0m"
end

def table_data
  cov_root = ENV.fetch('COVERAGE_ROOT')
  stats = JSON.parse(File.read("#{cov_root}/test_metrics.json"))

  cov_json = JSON.parse(File.read("#{cov_root}/coverage_metrics.json"))
  test_cov = cov_json['groups'][ENV.fetch('COVERAGE_TEST_TAB_NAME')]
  code_cov = cov_json['groups'][ENV.fetch('COVERAGE_CODE_TAB_NAME')]

  [
    [ nil ],
    [ 'test.count',    stats['test_count'],    '>=',  50 ],
    [ 'test.duration', stats['total_time'],    '<=',  10 ],
    [ nil ],
    [ 'test.failures', stats['failure_count'], '==',  0 ],
    [ 'test.errors',   stats['error_count'  ], '==',  0 ],
    [ 'test.skips',    stats['skip_count'   ], '==',  0 ],
    [ nil ],
    [ 'test.lines.total',      test_cov['lines'   ]['total' ], '<=', 644 ],
    [ 'test.lines.missed',     test_cov['lines'   ]['missed'], '==',   0 ],
    [ 'test.branches.total',   test_cov['branches']['total' ], '==',   0 ],
    [ 'test.branches.missed',  test_cov['branches']['missed'], '==',   0 ],
    [ nil ],
    [ 'code.lines.total',      code_cov['lines'   ]['total' ], '<=', 460 ],
    [ 'code.lines.missed',     code_cov['lines'   ]['missed'], '==',   0 ],
    [ 'code.branches.total',   code_cov['branches']['total' ], '<=',  66 ],
    [ 'code.branches.missed',  code_cov['branches']['missed'], '==',   0 ],
  ]
end

results = []
table_data.each do |name, value, op, limit|
  if name.nil?
    puts
    next
  end
  # puts "name=#{name}, value=#{value}, op=#{op}, limit=#{limit}"  # debug
  result = eval("#{value} #{op} #{limit}")
  puts '%s | %s %s %s | %s' % [
    name.rjust(25), value.to_s.rjust(5), "  #{op}", limit.to_s.rjust(5), coloured(result)
  ]
  results << result
end
puts
exit results.all?
