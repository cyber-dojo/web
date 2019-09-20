require_relative 'app_models_test_base'
require_relative '../../app/models/saver_asserter'
require 'json'

class SaverAsserterTest < AppModelsTestBase

  def self.hex_prefix
    'A27'
  end

  include SaverAsserter

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CB1', %w(
  when command succeeds
  then saver_assert(command) succeeds
  and returns the result
  ) do
    saver_assert_batch(
      ['create','Se/45/56'],
      ['exists?','Se/45/56'],
      ['write','Se/45/56/manifest.json','{"name":"bert"}'],
    )
    result = saver_assert(['read','Se/45/56/manifest.json'])
    assert_equal '{"name":"bert"}', result
  end

  test 'CB2', %w(
  when command fails
  then saver_assert(command) raises SaverService::Error
  with a json error.message
  ) do
    error = assert_raises(SaverService::Error) {
      saver_assert(['read','er/df/gh/yu/gh/manifest.json'])
    }
    actual = JSON.parse(error.message)
    expected = {
      'name' => 'read',
      'arg[0]' => 'er/df/gh/yu/gh/manifest.json',
      'result' => false
    }
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '967', %w(
  when all commands succeed
  then saver_assert_batch(commands) succeeds
  and returns an array of the results
  ) do
    results = saver_assert_batch(
      ['create','34/45/56'],
      ['exists?','34/45/56'],
      ['write','34/45/56/manifest.json','{"name":"bob"}'],
      ['read','34/45/56/manifest.json']
    )
    assert_equal [true,true,true,'{"name":"bob"}'], results
  end

  test '968', %w(
  when any command fails
  saver_assert_batch(commands) raises a SaverService::Error
  with a json error.message
  ) do
    error = assert_raises(SaverService::Error) {
      saver_assert_batch(
        ['create','qw/jk/56'],
        ['exists?','qw/jk/56'],
        ['read','qw/jk/56/manifest.json']
      )
    }
    actual = JSON.parse(error.message)
    expected = [
      { 'name' => 'create',  'arg[0]' => 'qw/jk/56', 'result' => true },
      { 'name' => 'exists?', 'arg[0]' => 'qw/jk/56', 'result' => true },
      { 'name' => 'read',    'arg[0]' => 'qw/jk/56/manifest.json', 'result' => false }
    ]
    assert_equal expected, actual
  end

end
