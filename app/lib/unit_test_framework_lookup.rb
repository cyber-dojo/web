
module UnitTestFrameworkLookup

  module_function

  def lookup(display_name)
    table = {
      'C (clang), assert' => 'cassert',
      'C (gcc), assert'   => 'cassert',
      'Ruby, Test::Unit'  => 'ruby_test_unit',
      'Java, JUnit'       => 'junit',
      'C#, NUnit'         => 'nunit'
    }
    table[display_name]
  end

end

# Used by test/lib/stub_runner
# Used by test/app_models/delta_maker