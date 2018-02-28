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
      return {
        "display_name"       => "Ruby, MiniTest",
        "exercise"           => "Fizz_Buzz",
        "image_name"         => "cyberdojofoundation/ruby_mini_test",
        "filename_extension" => ".rb",
        "tab_size"           => 2,
        "runner_choice"      => "stateless",
        "visible_files"      => {
          "test_hiker.rb" => "require './hiker'\nrequire 'minitest/autorun'\n\nclass TestHiker < MiniTest::Test\n\n  def test_life_the_universe_and_everything\n    assert_equal 42, answer\n  end\n\nend\n",
          "hiker.rb"      => "\ndef answer\n  6 * 9\nend\n",
          "cyber-dojo.sh" => "for test_file in *test*.rb\ndo\n  ruby $test_file\ndone\n",
          "output"        => "",
          "instructions"  => "Write a program that prints the numbers from 1 to 100."
        }
      }
    end
    if [display_name,exercise_name] == ['Ruby, RSpec','Fizz_Buzz']
      return {
        "display_name"       => "Ruby, RSpec",
        "exercise"           => "Fizz_Buzz",
        "image_name"         => "cyberdojofoundation/ruby_rspec",
        "filename_extension" => ".rb",
        "tab_size"           => 2,
        "runner_choice"      => "stateful",
        "visible_files"      => {
          "hiker_spec.rb" => "require './hiker'\n\ndescribe \"hiker\" do\n\n  context \"life the universe and everything\" do\n    it \"multiplies correctly\" do\n      expect(answer).to eq(42)\n    end\n  end\n\nend\n",
          "hiker.rb"      => "\ndef answer\n  6 * 9\nend\n",
          "cyber-dojo.sh" => "# Test output can be formatted as progress or documentation\nrspec . --format progress",
          "output"        => "",
          "instructions"  => "Write a program that prints the numbers from 1 to 100."
        }
      }
    end
    if [display_name,exercise_name] == ['Ruby, Test::Unit','Fizz_Buzz']
      return {
        "display_name"       => "Ruby, Test::Unit",
        "exercise"           => "Fizz_Buzz",
        "image_name"         => "cyberdojofoundation/ruby_test_unit",
        "filename_extension" => ".rb",
        "tab_size"           => 2,
        "runner_choice"      => "processful",
        "visible_files"      => {
          "test_hiker.rb" => "require './hiker'\nrequire 'test/unit'\n\nclass TestHiker < Test::Unit::TestCase\n\n  def test_life_the_universe_and_everything\n    assert_equal 42, answer\n  end\n\nend\n",
          "hiker.rb"      => "\ndef answer\n  6 * 9\nend\n",
          "cyber-dojo.sh" => "for test_file in *test*.rb\ndo\n  ruby $test_file\ndone\n",
          "output"        => "",
          "instructions"  => "Write a program that prints the numbers from 1 to 100."
        }
      }
    end
    if [display_name,exercise_name] == ['Java, JUnit','Fizz_Buzz']
      return {
        "display_name"       => "Java, JUnit",
        "exercise"           => "Fizz_Buzz",
        "image_name"         => "cyberdojofoundation/java_junit",
        "filename_extension" => ".java",
        "progress_regexs"    => [
          "Tests run\\: (\\d)+,(\\s)+Failures\\: (\\d)+",
          "OK \\((\\d)+ test(s)?\\)"
        ],
        "runner_choice"      => "stateless",
        "visible_files"      => {
          "HikerTest.java" => java_junit_hikertest_java,
          "Hiker.java"     => java_junit_hiker_java,
          "cyber-dojo.sh"  => java_junit_cyber_dojo_sh,
          "output"         => "",
          "instructions"   => "Write a program that prints the numbers from 1 to 100."
        }
      }
    end
  end

  private

  def java_junit_cyber_dojo_sh
    <<~'JAVA'
    CLASSES=.:`ls /junit/*.jar | tr '\n' ':'`
    javac -Xlint:unchecked -Xlint:deprecation -cp $CLASSES  *.java
    if [ $? -eq 0 ]; then
      # run test classes even if they are inner classes
      # remove voluminous stack trace from output
      java -cp $CLASSES org.junit.runner.JUnitCore \
        `ls -1 *Test*.class | grep -v '\\$' | sed 's/\(.*\)\..*/\1/'` \
        | grep -Ev 'org.junit.runner|org.junit.internal|sun.reflect|org.junit.Assert|java.lang.reflect|org.hamcrest'
    fi
    JAVA
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

end
