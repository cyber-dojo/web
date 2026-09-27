require 'simplecov'
require 'json'

# A SimpleCov formatter writing coverage_metrics.json. SimpleCov ships its own
# JSON formatter, shaped per file rather than per group, so this one carries its
# own name rather than reopening that class and redefining its format method.
# Redefining it makes ruby -w report the redefinition.
#
# based on https://github.com/vicentllongo/simplecov-json
# Each group sits at the top level, so a limits file can name a metric by the
# path that reads like one: code.lines.total. Mirrors
# https://github.com/cyber-dojo/saver
class CoverageMetricsFormatter

  # Writes the run's per-group line and branch counts, and returns them as JSON.
  def format(result)
    data = {
      timestamp: result.created_at.to_i,
      command_name: result.command_name
    }
    result.groups.each do |name, file_list|
      data[name] = {
        lines: {
          total: file_list.lines_of_code,
          covered: file_list.covered_lines,
          missed: file_list.missed_lines
        },
        branches: {
          total: file_list.total_branches,
          covered: file_list.covered_branches,
          missed: file_list.missed_branches
        }
      }
    end
    File.open(output_filepath, 'w+') do |file|
      file.print(JSON.pretty_generate(data))
    end
    puts output_message(result)
    data.to_json
  end

  # Where this run's metrics are written.
  def output_filepath
    File.join(output_path, output_filename)
  end

  # The name every sibling repo's metrics file has.
  def output_filename
    'coverage_metrics.json'
  end

  # The one-line summary printed at the end of a run.
  def output_message(result)
    stats = "#{result.covered_lines} / #{result.total_lines} LOC (#{result.covered_percent.round(2)}%) covered."
    "Coverage report generated for #{result.command_name} to #{output_filepath}. #{stats}"
  end

  private

  # The directory SimpleCov was told to write its report to.
  def output_path
    SimpleCov.coverage_path
  end

end
