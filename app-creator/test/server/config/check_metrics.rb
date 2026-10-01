require 'json'

# Evaluates one json data file against one limits file, eg
#   ruby check_metrics.rb /tmp/coverage_metrics.json coverage_metrics_limits
# The limits file defines metrics(), a list of [dotted-path, operator, limit].
# Copied from ../saver, which is where this shape comes from.

def coloured(arg)
  red = 31
  green = 32
  colourize(arg ? green : red, arg)
end

def colourize(code, word)
  "\e[#{code}m #{word} \e[0m"
end

data = JSON.parse(File.read(ARGV[0]))
require_relative ARGV[1]  # metrics

results = []
metrics.each do |paths, op, limit|
  if paths.nil?
    puts
    next
  end
  value = data
  paths.split('.').each { |path| value = value[path] }

  result = eval("#{value} #{op} #{limit}")
  puts '%s | %s %s %s | %s' % [
    paths.rjust(35), value.to_s.rjust(5), "  #{op}", limit.to_s.rjust(5), coloured(result)
  ]
  results << result
end
puts
exit results.all?
