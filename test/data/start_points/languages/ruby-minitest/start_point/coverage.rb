require 'hirb'
require "simplecov"

# Based on https://github.com/chetan/simplecov-console
# - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copyright (c) 2012 Chetan Sarva
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# - - - - - - - - - - - - - - - - - - - - - - - - - -

class SimpleCov::Formatter::Console

  ATTRIBUTES = [:table_options]

  class << self
    attr_accessor(*ATTRIBUTES)
  end

  def format(result)
    IO.write('coverage.txt', to_s(result).join("\n"))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def to_s(result)
    root = Dir.pwd

    lines = [ '' ]

    lines << "COVERAGE: #{pct(result)} --" +
      " #{result.covered_lines}/#{result.total_lines}" +
      " lines in #{result.files.size} files"

    if root.nil? then
      return lines
    end

    files = result.files.sort{ |a,b| a.covered_percent <=> b.covered_percent }

    covered_files = 0
    files.select!{ |file|
      if file.covered_percent == 100 then
        covered_files += 1
        false
      else
        true
      end
    }

    if files.nil? or files.empty? then
      return lines
    end

    table = files.map do |f|
      { :coverage => pct(f),
        :lines => f.lines_of_code,
        :file => f.filename.gsub(root + "/", ''),
        :missed => f.missed_lines.count,
        :missing => missed(f.missed_lines).join(", ") }
    end

    if table.size > 15 then
      lines << "showing bottom (worst) 15 of #{table.size} files"
      table = table.slice(0, 15)
    end

    table_options = SimpleCov::Formatter::Console.table_options || {}

    s = Hirb::Helpers::Table.render(table, table_options).split(/\n/)
    s.pop
    lines << s.join("\n").gsub(/\d+\.\d+%/) { |m| m }

    if covered_files > 0 then
      lines << "#{covered_files} file(s) with 100% coverage not shown"
    end

    lines
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def missed(missed_lines)
    groups = {}
    base = nil
    previous = nil
    missed_lines.each do |src|
      ln = src.line_number
      if base && previous && (ln - 1) == previous
        groups[base] += 1
        previous = ln
      else
        base = ln
        groups[base] = 0
        previous = base
      end
    end

    group_str = []
    groups.map do |starting_line, length|
      if length > 0
        group_str << "#{starting_line}-#{starting_line + length}"
      else
        group_str << "#{starting_line}"
      end
    end

    group_str
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def pct(obj)
    sprintf("%6.2f%%", obj.covered_percent)
  end

end

SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.start
