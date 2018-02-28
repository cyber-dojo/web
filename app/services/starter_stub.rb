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
      'filename_extension' => '.rb',
      'tab_size'           => 2,
      'runner_choice'      => 'stateless',
      'visible_files'      => {
        'test_hiker.rb' => ruby_minitest_test_hiker_rb,
        'hiker.rb'      => ruby_minitest_hiker_rb,
        'cyber-dojo.sh' => ruby_minitest_cyber_dojo_sh,
        'output'        => '',
        'instructions'  => 'Write a program that prints the numbers from 1 to 100.'
      }
    }
  end

  def ruby_minitest_test_hiker_rb
    <<~'RUBY'
    require './hiker'
    require 'minitest/autorun'

    class TestHiker < MiniTest::Test
      def test_life_the_universe_and_everything
        assert_equal 42, answer
      end
    end
    RUBY
  end

  def ruby_minitest_hiker_rb
    <<~'RUBY'
    def answer
      6 * 9
    end
    RUBY
  end

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
      'filename_extension' => '.rb',
      'tab_size'           => 2,
      'runner_choice'      => 'stateful',
      'visible_files'      => {
        'hiker_spec.rb' => ruby_rspec_hiker_spec_rb,
        'hiker.rb'      => ruby_rspec_hiker_rb,
        'cyber-dojo.sh' => ruby_rspec_cyber_dojo_sh,
        'output'        => '',
        'instructions'  => 'Write a program that prints the numbers from 1 to 100.'
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
      'filename_extension' => '.rb',
      'tab_size'           => 2,
      'runner_choice'      => 'processful',
      'visible_files'      => {
        'test_hiker.rb' => ruby_test_unit_test_hiker_rb,
        'hiker.rb'      => ruby_test_unit_hiker_rb,
        'cyber-dojo.sh' => ruby_test_unit_cyber_dojo_sh,
        'output'        => '',
        'instructions'  => 'Write a program that prints the numbers from 1 to 100.'
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
      'filename_extension' => '.java',
      'progress_regexs'    => [
        "Tests run\\: (\\d)+,(\\s)+Failures\\: (\\d)+",
        "OK \\((\\d)+ test(s)?\\)"
      ],
      'runner_choice'      => 'stateless',
      'visible_files'      => {
        'HikerTest.java' => java_junit_hikertest_java,
        'Hiker.java'     => java_junit_hiker_java,
        'cyber-dojo.sh'  => java_junit_cyber_dojo_sh,
        'output'         => '',
        'instructions'   => 'Write a program that prints the numbers from 1 to 100.'
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
