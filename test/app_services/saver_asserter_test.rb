require_relative 'app_services_test_base'
require_relative '../../app/services/saver_asserter'

class SaverAsserterTest < AppServicesTestBase

  def self.hex_prefix
    'A27'
  end

  include SaverAsserter

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CB1',
  'saver_assert(false) raises SaverException' do
    assert_raises(SaverException) {
      saver_assert(false)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CB2',
  'saver_assert_true() does not raise' do
    saver_assert(true)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '968',
  'saver_assert_equal(arg,arg) does not raise' do
    saver_assert_equal([true,true], [true,true])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '967',
  'saver_assert_equal(arg,!arg) raises SaverException' do
    error = assert_raises(SaverException) do
      saver_assert_equal([true,true], [true,false])
    end
    expected = 'expected:[true, false],actual:[true, true]'
    assert_equal expected, error.message
  end

end
