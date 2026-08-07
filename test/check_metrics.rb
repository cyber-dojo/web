require 'json'

# Checks a metrics report against the bounds in a params file - the same file
# the CI policy evaluates - so a limit is written once and applied in both
# places. Mirrors metrics-compliance.rego in kosli-attestation-types.
#
#   ruby check_metrics.rb <metrics.json> <params.json>

# The value in green when the bound was met, red when it was not.
def coloured(arg)
  red = 31
  green = 32
  colourize(arg ? green : red, arg)
end

# The word wrapped in an ANSI colour code.
def colourize(code, word)
  "\e[#{code}m #{word} \e[0m"
end

# Every numeric leaf of a bounds tree, as [path, bound] pairs, where path is an
# array of keys. The same walk the policy does, so both read one params file.
def bounds(tree, path = [])
  return [[path, tree]] if tree.is_a?(Numeric)
  return [] unless tree.is_a?(Hash)

  tree.flat_map { |key, value| bounds(value, path + [key]) }
end

# The metric at the given path, or nil when the report does not carry it.
def metric_at(data, path)
  path.reduce(data) { |node, key| node.is_a?(Hash) ? node[key] : nil }
end

# Prints one row and answers whether its bound was met. A metric the report
# does not carry fails, rather than being silently skipped.
def check(data, path, bound, operator)
  value = metric_at(data, path)
  met = value.is_a?(Numeric) && value.public_send(operator, bound)
  puts format('%s | %s %s %s | %s',
              path.join('.').rjust(35),
              (value.nil? ? 'absent' : value).to_s.rjust(5),
              "  #{operator}",
              bound.to_s.rjust(5),
              coloured(met))
  met
end

# Prints every bound of one tree, and answers whether all were met.
def check_all(data, tree, operator)
  results = bounds(tree).sort.map { |path, bound| check(data, path, bound, operator) }
  puts unless results.empty?
  results
end

data = JSON.parse(File.read(ARGV[0]))
params = JSON.parse(File.read(ARGV[1]))

puts
results = check_all(data, params['min'] || {}, :>=)
results += check_all(data, params['max'] || {}, :<=)

# Params naming no bounds would pass vacuously, as they would in the policy.
if results.empty?
  puts 'params name no bounds, so nothing is being checked'
  exit false
end

exit results.all?
