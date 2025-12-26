# frozen_string_literal: true
require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require 'json'

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
    stdout,stderr = capture_stdout_stderr do        
      error = assert_raises(RunnerService::Error) { runner.ready? }
      assert_equal 'body is not JSON', error.message, :error_message
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A8',
  'ready? smoke test' do
    assert runner.ready?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '812',
  'run() tests expecting 42 actual 6*9' do
    in_new_kata { |kata|
      json = runner.run_cyber_dojo_sh(run_args(kata))
      stdout = json['stdout']['content']
      assert stdout.include?('not ok 1 life the universe and everything'), json
      assert stdout.include?('in test file test_hiker.sh'), json
      assert stdout.include?('[ "$actual" == "42" ]'), json
      assert_equal 'red', json['outcome'], json
    }
  end

  private

  def run_args(kata)
    {
      id: kata.id,
      files: plain(kata.event(-1)['files']),
      manifest: {
        image_name: kata.manifest['image_name'],
        max_seconds: kata.manifest['max_seconds']
      }
    }
  end

end
