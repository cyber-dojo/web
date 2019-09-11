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
    error = assert_raises(SaverException) {
      saver_assert(false)
    }
    assert_equal 'false', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CB2',
  'saver_assert(true) does not raise' do
    saver_assert(true)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '968',
  'saver_assert_batch(commands) raises SaverException when any command fails' do
    error = assert_raises(SaverException) {
      saver_assert_batch([
        ['read','a/b/c/d/e/44/67/89']
      ])
    }
    assert_equal '[false]', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '967',
  'saver_assert_batch(commands) does not raise when all commands succeed' do
    saver_assert_batch([
      ['create','34/45/56'],
      ['exists?','34/45/56'],
      ['write','34/45/56/manifest.json','{"name":"bob"}'],
      ['read','34/45/56/manifest.json']
    ])
  end

end
