require_relative 'http_helper'

class StarterStub

  def initialize(_)
  end

  def language_manifest(display_name, exercise_name)
    # Important not to make these returned Constants
    # because I manipulate the manifest in tests,
    # eg deleting keys to test kata defaults and
    # eg setting specific id's to test kata.id completion.
    if [display_name,exercise_name] == ['Ruby, MiniTest','Fizz_Buzz']
      return ruby_minitest_fizz_buzz
    end
    if [display_name,exercise_name] == ['Ruby, RSpec','Fizz_Buzz']
      return ruby_rspec_fizz_buzz
    end
    if [display_name,exercise_name] == ['Ruby, Test::Unit','Fizz_Buzz']
      return ruby_test_unit_fizz_buzz
    end
    if [display_name,exercise_name] == ['Java, JUnit','Fizz_Buzz']
      return java_junit_fizz_buzz
    end
  end

  private

  def ruby_minitest_fizz_buzz
    {
      'display_name'       => 'Ruby, MiniTest',
      'exercise'           => 'Fizz_Buzz',
      'image_name'         => 'cyberdojofoundation/ruby_mini_test',
      'filename_extension' => ['.rb'],
      'tab_size'           => 2,
      'runner_choice'      => 'stateless',
      'visible_files'      => {
        'coverage.rb'   => ruby_minitest_coverage_rb,
        'test_hiker.rb' => ruby_minitest_test_hiker_rb,
        'hiker.rb'      => ruby_minitest_hiker_rb,
        'cyber-dojo.sh' => ruby_minitest_cyber_dojo_sh,
        'readme.txt'    => 'Write a program that prints the numbers from 1 to 100.'
      },
      'hidden_filenames' => [
        "coverage/\\.last_run\\.json",
        "coverage/\\.resultset\\.json"
      ]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def ruby_minitest_coverage_rb
    <<~'RUBY'
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
    RUBY
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def ruby_minitest_test_hiker_rb
    <<~'RUBY'
    require_relative 'coverage'
    require_relative 'hiker'
    require 'minitest/autorun'

    class TestHiker < MiniTest::Test
      def test_life_the_universe_and_everything
        assert_equal 42, answer
      end
    end
    RUBY
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def ruby_minitest_hiker_rb
    <<~'RUBY'
    def answer
      6 * 9
    end
    RUBY
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def ruby_minitest_cyber_dojo_sh
    <<~'SHELL'
    for test_file in *test*.rb
    do
      ruby $test_file
    done
    SHELL
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def ruby_rspec_fizz_buzz
    {
      'display_name'       => 'Ruby, RSpec',
      'exercise'           => 'Fizz_Buzz',
      'image_name'         => 'cyberdojofoundation/ruby_rspec',
      'filename_extension' => ['.rb'],
      'tab_size'           => 2,
      'runner_choice'      => 'stateful',
      'visible_files'      => {
        'hiker_spec.rb' => ruby_rspec_hiker_spec_rb,
        'hiker.rb'      => ruby_rspec_hiker_rb,
        'cyber-dojo.sh' => ruby_rspec_cyber_dojo_sh,
        'readme.txt'    => 'Write a program that prints the numbers from 1 to 100.'
      }
    }
  end

  def ruby_rspec_hiker_spec_rb
    <<~'RUBY'
    require './hiker'

    describe "hiker" do
      context "life the universe and everything" do
        it "multiplies correctly" do
          expect(answer).to eq(42)
        end
      end
    end
    RUBY
  end

  def ruby_rspec_hiker_rb
    <<~'RUBY'
    def answer
      6 * 9
    end
    RUBY
  end

  def ruby_rspec_cyber_dojo_sh
    <<~'SHELL'
    # Test output can be formatted as progress or documentation
    rspec . --format progress
    SHELL
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def ruby_test_unit_fizz_buzz
    {
      'display_name'       => 'Ruby, Test::Unit',
      'exercise'           => 'Fizz_Buzz',
      'image_name'         => 'cyberdojofoundation/ruby_test_unit',
      'filename_extension' => ['.rb'],
      'tab_size'           => 2,
      'runner_choice'      => 'processful',
      'visible_files'      => {
        'test_hiker.rb' => ruby_test_unit_test_hiker_rb,
        'hiker.rb'      => ruby_test_unit_hiker_rb,
        'cyber-dojo.sh' => ruby_test_unit_cyber_dojo_sh,
        'readme.txt'    => 'Write a program that prints the numbers from 1 to 100.'
      }
    }
  end

  def ruby_test_unit_test_hiker_rb
    <<~'RUBY'
    require './hiker'
    require 'test/unit'

    class TestHiker < Test::Unit::TestCase
      def test_life_the_universe_and_everything
        assert_equal 42, answer
      end
    end
    RUBY
  end

  def ruby_test_unit_hiker_rb
    <<~'RUBY'
    def answer
      6 * 9
    end
    RUBY
  end

  def ruby_test_unit_cyber_dojo_sh
    <<~'SHELL'
    for test_file in *test*.rb
    do
      ruby $test_file
    done
    SHELL
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def java_junit_fizz_buzz
    {
      'display_name'       => 'Java, JUnit',
      'exercise'           => 'Fizz_Buzz',
      'image_name'         => 'cyberdojofoundation/java_junit',
      'filename_extension' => ['.java'],
      'progress_regexs'    => [
        "Tests run\\: (\\d)+,(\\s)+Failures\\: (\\d)+",
        "OK \\((\\d)+ test(s)?\\)"
      ],
      'runner_choice'      => 'stateless',
      'visible_files'      => {
        'HikerTest.java' => java_junit_hikertest_java,
        'Hiker.java'     => java_junit_hiker_java,
        'cyber-dojo.sh'  => java_junit_cyber_dojo_sh,
        'readme.txt'     => 'Write a program that prints the numbers from 1 to 100.'
      }
    }
  end

  def java_junit_hiker_java
    <<~JAVA
    public class Hiker {
        public static int answer() {
            return 6 * 9;
        }
    }
    JAVA
  end

  def java_junit_hikertest_java
    <<~JAVA
    import org.junit.*;
    import static org.junit.Assert.*;

    public class HikerTest {
        @Test
        public void life_the_universe_and_everything() {
            int expected = 42;
            int actual = Hiker.answer();
            assertEquals(expected, actual);
        }
    }
    JAVA
  end

  def java_junit_cyber_dojo_sh
    <<~'SHELL'
    CLASSES=.:`ls /junit/*.jar | tr '\n' ':'`
    javac -Xlint:unchecked -Xlint:deprecation -cp $CLASSES  *.java
    if [ $? -eq 0 ]; then
      # run test classes even if they are inner classes
      # remove voluminous stack trace from output
      java -cp $CLASSES org.junit.runner.JUnitCore \
        `ls -1 *Test*.class | grep -v '\\$' | sed 's/\(.*\)\..*/\1/'` \
        | grep -Ev 'org.junit.runner|org.junit.internal|sun.reflect|org.junit.Assert|java.lang.reflect|org.hamcrest'
    fi
    SHELL
  end

end
