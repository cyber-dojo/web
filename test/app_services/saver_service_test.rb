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

    # run
    assert_equal true, saver.run(saver.create_command(dirname))
    assert_equal true, saver.run(saver.exists_command(dirname))
    assert_equal true, saver.run(saver.write_command(filename, content))
    assert_equal true, saver.run(saver.append_command(filename, content))
    assert_equal content*2, saver.run(saver.read_command(filename))
    assert_raises(SaverService::Error) {
      saver.run(saver.exists_command(42))
    }

    # assert
    assert_equal content*2, saver.assert(saver.read_command(filename))
    assert_raises(SaverService::Error) {
      saver.assert(saver.exists_command(dirname+'42'))
    }

    # assert_all
    assert_equal [true,content*2], saver.assert_all([
      saver.exists_command(dirname),
      saver.read_command(filename)
    ])
    # run_all
    assert_equal [true,content*2], saver.run_all([
      saver.exists_command(dirname),
      saver.read_command(filename)
    ])
    # run_until_true
    assert_equal [false,false,true], saver.run_until_true([
      saver.exists_command(dirname+'1'),
      saver.exists_command(dirname+'2'),
      saver.exists_command(dirname),
      saver.exists_command(dirname+'3')
    ])
    # run_until_false
    assert_equal [true,true,false], saver.run_until_false([
      saver.exists_command(dirname),
      saver.exists_command(dirname),
      saver.exists_command(dirname+'42'),
      saver.exists_command(dirname),
    ])
  end

end
