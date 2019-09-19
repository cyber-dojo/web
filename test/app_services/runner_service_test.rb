require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require_relative '../../app/services/runner_service'

class RunnerServiceTest < AppServicesTestBase

  def self.hex_prefix
    '2BD'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(RunnerService::Error) { runner.sha }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74F',
  'smoke test sha' do
    assert_sha(runner.sha)
  end

  test '3A8',
  'smoke test ready?' do
    assert runner.ready?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '812',
  'run() tests expecting 42 actual 6*9' do
    in_kata { |kata|
      result = runner.run_cyber_dojo_sh(*run_args(kata))
      stdout = result['stdout']['content']
      # output == Ruby, MiniTest
      assert stdout.include?('Expected: 42'), result
      assert stdout.include?('  Actual: 54'), result
      assert_equal '', result['stderr']['content'], result
      assert_equal 1, result['status'], result
      refute result['timed_out'], result
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC',
  'deleting a file' do
    in_kata { |kata|
      args = run_args(kata)
      files = args[2]
      files['cyber-dojo.sh'] += "\nrm readme.txt"
      args = [
        kata.manifest.image_name,
        kata.id,
        files,
        kata.manifest.max_seconds
      ]
      result = runner.run_cyber_dojo_sh(*args)
      assert_equal ['readme.txt'], result['deleted']
    }
  end

  private

  def run_args(kata)
    [ kata.manifest.image_name,
      kata.id,
      plain(kata.files),
      kata.manifest.max_seconds
    ]
  end

end
