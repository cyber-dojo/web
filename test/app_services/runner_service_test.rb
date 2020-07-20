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
    error = assert_raises(RunnerService::Error) { runner.ready? }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A8',
  'smoke test ready?' do
    assert runner.ready?['ready?']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '812',
  'run() tests expecting 42 actual 6*9' do
    in_new_kata { |kata|
      json = runner.run_cyber_dojo_sh(run_args(kata))
      key = 'run_cyber_dojo_sh'
      stdout = json[key]['stdout']['content']
      assert stdout.include?('Expected: 42'), json
      assert stdout.include?('  Actual: 54'), json
      assert_equal 'red', json[key]['outcome'], json
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC',
  'deleting a file' do
    in_new_kata { |kata|
      args = run_args(kata)
      args[:files]['cyber-dojo.sh'] = 'rm readme.txt'
      json = runner.run_cyber_dojo_sh(args)
      result = json['run_cyber_dojo_sh']
      assert_equal ['readme.txt'], result['deleted']
    }
  end

  private

  def run_args(kata)
    {
      id: kata.id,
      files: plain(kata.files),
      manifest: {
        image_name: kata.manifest.image_name,
        max_seconds: kata.manifest.max_seconds
      }
    }
  end

end
