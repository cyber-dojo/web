require 'simplecov'
require 'json'

# A SimpleCov formatter writing coverage_metrics.json, which check_metrics
# reads. SimpleCov ships its own JSON formatter, shaped per file rather than
# per group, so this one carries its own name rather than reopening that class
# and redefining its format method. Redefining it makes ruby -w report the
# redefinition.
#
# based on https://github.com/vicentllongo/simplecov-json
class CoverageMetricsFormatter
  def format(result)
    groups = {}
    result.groups.each do |name, file_list|
      groups[name] = {
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
    data = {
      timestamp: result.created_at.to_i,
      command_name: result.command_name,
      groups: groups
    }
    File.open(output_filepath, 'w+') do |file|
      file.print(JSON.pretty_generate(data))
    end
    puts output_message(result)
    data.to_json
  end

  def output_filepath
    File.join(output_path, output_filename)
  end

  def output_filename
    'coverage_metrics.json'
  end

  def output_message(result)
    "Coverage report generated for #{result.command_name} to #{output_filepath}. #{result.covered_lines} / #{result.total_lines} LOC (#{result.covered_percent.round(2)}%) covered."
  end

  private

  def output_path
    SimpleCov.coverage_path
  end
end
