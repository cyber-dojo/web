require_relative 'lib_test_base'

class NameOfCallerTest < LibTestBase

  test '07ADA9',
  'name of caller is name of callers method' do
    assert_equal 'helper1', helper1
  end

  test '3615C2',
  'name of caller is name of callers method' do
    assert_equal 'helper3', helper3
  end

  private

  def helper1
    helper2
  end

  def helper2
    name_of(caller)
  end

  def helper3
    helper4
  end

  def helper4
    name_of(caller)
  end

  include NameOfCaller

end
