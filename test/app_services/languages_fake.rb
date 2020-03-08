# frozen_string_literal: true

class LanguagesFake

  def initialize(_externals)
  end

  def ready?
    true
  end

  def names
    NAMES
  end

  def manifests
    nil
  end

  def manifest(name)
    MANIFESTS[name].clone
  end

  private

  NAMES = [
      "Asm, assert", "BCPL, all_tests_passed",
      "Bash, bash_unit", "Bash, bats", "Bash, shunit2",
      "C (clang), Cgreen", "C (clang), assert", "C (gcc), Cgreen",
      "C (gcc), CppUTest", "C (gcc), GoogleTest", "C (gcc), assert",
      "C#, Moq", "C#, NUnit", "C#, SpecFlow", "C++ (clang++), Cgreen",
      "C++ (clang++), GoogleMock", "C++ (clang++), GoogleTest",
      "C++ (clang++), Igloo", "C++ (clang++), assert", "C++ (g++), Boost.Test",
      "C++ (g++), Catch", "C++ (g++), Cgreen", "C++ (g++), CppUTest",
      "C++ (g++), Cucumber-cpp", "C++ (g++), GoogleMock", "C++ (g++), GoogleTest",
      "C++ (g++), Igloo", "C++ (g++), assert", "Chapel, assert", "Clojure, Midje",
      "Clojure, clojure.test", "CoffeeScript, jasmine", "D, unittest",
      "Elixir, ExUnit", "Erlang, eunit", "F#, NUnit", "Fortran, FUnit",
      "Go, testing", "Groovy, JUnit", "Groovy, Spock", "Haskell, hunit",
      "Java, Approval", "Java, Cucumber", "Java, Cucumber-Spring", "Java, Cucumber3-Spring",
      "Java, JMock", "Java, JUnit", "Java, JUnit-Sqlite", "Java, Mockito",
      "Java, PowerMockito", "Javascript, Cucumber", "Javascript, Mocha+chai+sinon",
      "Javascript, assert", "Javascript, assert+jQuery", "Javascript, jasmine",
      "Javascript, qunit+sinon", "Kotlin, Kotlintest", "PHP, PHPUnit",
      "Pascal (FreePascal), assert", "Perl, Test::Simple", "Python, assert",
      "Python, behave", "Python, pytest", "Python, unittest", "R, RUnit",
      "Ruby, Approval", "Ruby, Cucumber", "Ruby, MiniTest", "Ruby, RSpec",
      "Ruby, Test::Unit", "Rust, test", "Swift, Swordfish", "Swift, XCTest",
      "VHDL, assert", "VisualBasic, NUnit", "Zig, test"
    ]

  RUBY_MINITEST_MANIFEST = {
    "display_name" => "Ruby, MiniTest",
    "hidden_filenames" => [
      "coverage/\\.last_run\\.json",
      "coverage/\\.resultset\\.json"
    ],
    "image_name" => "cyberdojofoundation/ruby_mini_test",
    "filename_extension" => [ ".rb" ],
    "tab_size" => 2,
    "visible_files" => {
      "test_hiker.rb" => {
        "content" => "require_relative 'coverage'\nrequire_relative 'hiker'\nrequire 'minitest/autorun'\n\nclass TestHiker < MiniTest::Test\n\n  def test_life_the_universe_and_everything\n    assert_equal 42, answer\n  end\n\nend\n"
      },
      "hiker.rb" => {
        "content" => "\ndef answer\n  6 * 9\nend\n"
      },
      "cyber-dojo.sh" => {
        "content" => "for test_file in *test*.rb\ndo\n  ruby $test_file\ndone\n"
      },
      "coverage.rb" => {
        "content" => "require 'simplecov'\nrequire 'simplecov-console'\nSimpleCov.formatter = SimpleCov::Formatter::Console\nSimpleCov.start\n"
      }
    }
  }

  CSHARP_NUNIT_MANIFEST = {
    "display_name" => "C#, NUnit",
    "hidden_filenames" => [
      "TestResult\\.xml"
    ],
    "image_name" => "cyberdojofoundation/csharp_nunit",
    "filename_extension" => [ ".cs" ],
    "visible_files" => {
      "HikerTest.cs" => {
        "content" => "using NUnit.Framework;\n\n[TestFixture]\npublic class HikerTest\n{\n    [Test]\n    public void life_the_universe_and_everything()\n    {\n        // a simple example to start you off\n        Assert.AreEqual(42, Hiker.Answer);\n    }\n}\n"
      },
      "Hiker.cs" => {
        "content" => "public class Hiker\n{\n    public static int Answer\n    {\n        get { return 6 * 9; }\n    }\n}\n"
      },
      "cyber-dojo.sh" => {
        "content" => "NUNIT_PATH=/nunit/lib/net45\nexport MONO_PATH=${NUNIT_PATH}\n\nmcs -t:library \\\n  -r:${NUNIT_PATH}/nunit.framework.dll \\\n  -out:RunTests.dll *.cs\n\nif [ $? -eq 0 ]; then\n  NUNIT_RUNNERS_PATH=/nunit/tools\n  mono ${NUNIT_RUNNERS_PATH}/nunit3-console.exe --noheader ./RunTests.dll\nfi\n"
      }
    }
  }

  RUBY_RSPEC_MANIFEST = {
    "display_name" => "Ruby, RSpec",
    "hidden_filenames" => [
      "coverage/\\.last_run\\.json",
      "coverage/\\.resultset\\.json"
    ],
    "image_name" => "cyberdojofoundation/ruby_rspec",
    "filename_extension" => [ ".rb" ],
    "tab_size" => 2,
    "visible_files" => {
      "hiker_spec.rb" => {
        "content" => "require_relative 'coverage'\nrequire_relative 'hiker'\n\ndescribe \"hiker\" do\n\n  context \"life the universe and everything\" do\n    it \"multiplies correctly\" do\n      expect(answer).to eq(42)\n    end\n  end\n\nend\n"
      },
      "hiker.rb" => {
        "content" => "\ndef answer\n  6 * 9\nend\n"
      },
      "cyber-dojo.sh" => {
        "content" => "# Test output can be formatted as progress or documentation\nrspec . --format progress"
      },
      "coverage.rb" => {
        "content" => "require 'simplecov'\nrequire 'simplecov-console'\nSimpleCov.formatter = SimpleCov::Formatter::Console\nSimpleCov.start\n"
      }
    }
  }

  JAVA_JUNIT_MANIFEST = {
    "display_name" => "Java, JUnit",
    "image_name" => "cyberdojofoundation/java_junit",
    "filename_extension" => [ ".java" ],
    "progress_regexs" => [
      "Tests run\\: (\\d)+,(\\s)+Failures\\: (\\d)+",
      "OK \\((\\d)+ test(s)?\\)"
    ],
    "visible_files" => {
      "HikerTest.java" => {
        "content" => "import org.junit.*;\n\nimport static org.junit.Assert.*;\nimport static org.assertj.core.api.Assertions.assertThat;\n\npublic class HikerTest {\n\n    @Test\n    public void life_the_universe_and_everything() {\n        // a simple example to get you started\n        int expected = 42;\n        int actual = Hiker.answer();\n        // JUnit assertion - the default Java assertion library\n        // https://junit.org/junit4/\n        assertEquals(expected, actual);\n        // assertJ assertion - fluent assertions for Java\n        // http://joel-costigliola.github.io/assertj/\n        assertThat(actual).isEqualTo(expected);\n    }\n}\n"
      },
      "Hiker.java" => {
        "content" => "\npublic class Hiker {\n\n    public static int answer() {\n        return 6 * 9;\n    }\n}\n"
      },
      "cyber-dojo.sh" => {
        "content" => "\nCLASSES=.:`ls /junit/*.jar | tr '\\n' ':'`\njavac -Xlint:unchecked -Xlint:deprecation -cp $CLASSES  *.java\nif [ $? -eq 0 ]; then\n  # run test classes even if they are inner classes\n  # remove voluminous stack trace from output\n  java -cp $CLASSES org.junit.runner.JUnitCore \\\n    `ls -1 *Test*.class | grep -v '\\\\$' | sed 's/\\(.*\\)\\..*/\\1/'` \\\n    | grep -Ev 'org.junit.runner|org.junit.internal|sun.reflect|org.junit.Assert|java.lang.reflect|org.hamcrest'\nfi\n"
      }
    }
  }

  PYTHON_UNITTEST_MANIFEST = {
    "display_name" => "Python, unittest",
    "hidden_filenames" => [ "\\.coverage" ],
    "image_name" => "cyberdojofoundation/python_unittest",
    "filename_extension" => [ ".py" ],
    "tab_size" => 4,
    "progress_regexs" => [
      "FAILED \\(failures=\\d+\\)",
      "OK"
    ],
    "visible_files" => {
      "test_hiker.py" => {
        "content" => "import hiker\nimport unittest\n\nclass TestHiker(unittest.TestCase):\n\n    def test_life_the_universe_and_everything(self):\n        '''simple example to start you off'''\n        douglas = hiker.Hiker()\n        self.assertEqual(42, douglas.answer())\n\n\nif __name__ == '__main__':\n    unittest.main() # pragma: no cover\n"
      },
      "hiker.py" => {
        "content" => "class Hiker:\n\n    def answer(self):\n        return 6 * 9\n"
      },
      "cyber-dojo.sh" => {
        "content" => "set -e\ncoverage3 run -m unittest *test*.py\ncoverage3 report -m\n"
      }
    }
  }

  MANIFESTS = {
    'Ruby, MiniTest' => RUBY_MINITEST_MANIFEST,
    'C#, NUnit' => CSHARP_NUNIT_MANIFEST,
    'Ruby, RSpec' => RUBY_RSPEC_MANIFEST,
    'Java, JUnit' => JAVA_JUNIT_MANIFEST,
    'Python, unittest' => PYTHON_UNITTEST_MANIFEST
  }

end
