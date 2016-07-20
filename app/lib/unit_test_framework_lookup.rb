
# Maps from display_name to unit_test_framework.
# Used by test/lib/stub_runner.rb
# Used by test/app_models/delta_maker.rb
# Used by test/app_lib/output_colour_test.rb
# which were all written before the start-point re-architecture.

module UnitTestFrameworkLookup

  module_function

  def lookup(display_name)
    table = {
      'Asm, assert'               => 'cassert',
      'Bash, shunit2'             => 'bash_shunit2',
      'BCPL, all_tests_passed'    => 'bcpl_all_tests_passed',
      'C (clang), Cgreen'         => 'cgreen',
      'C (gcc), Cgreen'           => 'cgreen',
      'C (gcc), CppUTest'         => 'cpputest',
      'C (gcc), Unity'            => 'cunity',
      'C (clang), assert'         => 'cassert',
      'C (gcc), assert'           => 'cassert',
      'C#, Moq'                   => 'nunit',
      'C#, NUnit'                 => 'nunit',
      'C#, SpecFlow'              => 'nunit',
      'C++ (clang++), assert'     => 'cassert',
      'C++ (clang++), Cgreen'     => 'cgreen',
      'C++ (clang++), GoogleMock' => 'google_test',
      'C++ (clang++), GoogleTest' => 'google_test',
      'C++ (clang++), Igloo'      => 'cppigloo',
      'C++ (g++), assert'         => 'cassert',
      'C++ (g++), Boost.Test'     => 'boost_test',
      'C++ (g++), Catch'          => 'catch',
      'C++ (g++), Cgreen'         => 'cgreen',
      'C++ (g++), CppUTest'       => 'cpputest',
      'C++ (g++), GoogleMock'     => 'google_test',
      'C++ (g++), GoogleTest'     => 'google_test',
      'C++ (g++), Igloo'          => 'cppigloo',
      'Clojure, clojure.test'     => 'clojure_test',
      'Clojure, Midje'            => 'midje',
      'CoffeeScript, jasmine'     => 'coffeescript_jasmine',
      'D, unittest'               => 'd_unittest',
      'Erlang, eunit'             => 'eunit',
      'F#, NUnit'                 => 'nunit',
      'Fortran, FUnit'            => 'funit',
      'Go, testing'               => 'go_testing',
      'Groovy, JUnit'             => 'junit',
      'Groovy, Spock'             => 'groovy_spock',
      'Haskell, hunit'            => 'hunit',
      'Java, Cucumber'            => 'java_cucumber',
      'Java, JMock'               => 'junit',
      'Java, JUnit'               => 'junit',
      'Java, Mockito'             => 'junit',
      'Java, PowerMockito'        => 'junit',
      'Javascript, assert'        => 'node',
      'Javascript, jasmine'       => 'javascript_jasmine',
      'Javascript, Mocha+chai+sinon' => 'mocha',
      'Javascript, qunit+sinon'   => 'qunit',
      'Perl, Test::Simple'        => 'perl_test_simple',
      'PHP, PHPUnit'              => 'php_unit',
      'Python, py.test'           => 'python_pytest',
      'Python, unittest'          => 'python_unittest',
      'R, RUnit'                  => 'runit',
      'Ruby, Cucumber'            => 'ruby_rspec',
      'Ruby, RSpec'               => 'ruby_rspec',
      'Ruby, MiniTest'            => 'ruby_mini_test',
      'Ruby, Test::Unit'          => 'ruby_test_unit',
      'Rust, test'                => 'rust_test',
      'Scala, scalatest'          => 'scala_test',
      'Swift, XCTest'             => 'xctest',
      'VHDL, assert'              => 'vhdl_assert',
      'VisualBasic, NUnit'        => 'nunit'
    }
    table[display_name]
  end

end
