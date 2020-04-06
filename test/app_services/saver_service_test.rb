require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require_relative '../../app/services/saver_service'
require 'json'

class SaverServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D2w'
  end

  def hex_setup
    set_saver_class('SaverService')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A6', 'SaverExceptionRaiser raises exception' do
    set_saver_class('SaverExceptionRaiser')
    error = assert_raises(SaverService::Error) { saver.sha }
    assert error.message.start_with?('stub-raiser'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body get failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(SaverService::Error) { saver.ready? }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '442',
  'smoke test ready?' do
    assert saver.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '443',
  'smoke test saver methods' do
    dirname = 'katas/34/56/7W'
    filename = dirname + '/' + '7.events.json'
    content = '{"colour":"red"}'
    assert_equal true, saver.create(dirname)
    assert_equal true, saver.exists?(dirname)
    assert_equal true, saver.write(filename, content)
    assert_equal true, saver.append(filename, content)
    assert_equal content*2, saver.read(filename)
    assert_equal content*2, saver.assert(['read',filename])
    assert_equal [true,content*2], saver.batch_assert([
      ['exists?',dirname],
      ['read',filename]
    ])
    assert_equal [true,content*2], saver.batch([
      ['exists?',dirname],
      ['read',filename]
    ])
    assert_equal [false,false,true], saver.batch_until_true([
      ['exists?',dirname+'1'],
      ['exists?',dirname+'2'],
      ['exists?',dirname],
      ['exists?',dirname+'3'],
    ])
    assert_equal [true,true,false], saver.batch_until_false([
      ['exists?',dirname],
      ['exists?',dirname],
      ['exists?',dirname+'42'],
      ['exists?',dirname],
    ])
    assert_raises(SaverService::Error) { saver.exists?(42) }
    assert_raises(SaverService::Error) {
      saver.assert(['exists?',dirname+'42'])
    }
  end

end
