require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require 'json'

class DifferServiceTest < AppServicesTestBase

  def hex_setup
    set_class('differ', 'DifferService')
  end

  test 'F7C4D1',
  'response.body failure is mapped to DifferService::Error' do
    set_http(HttpJsonRequesterNotJsonStub)
    _stdout, _stderr = capture_stdout_stderr do
      error = assert_raises(DifferService::Error) { differ.diff_summary('id', 0, 0) }
      assert_equal 'body is not JSON', error.message
    end
  end

  test 'F7C4D2',
  'diff_summary() returns the changed file' do
    manifest = starter_manifest
    id = saver.kata_create(manifest)
    files = manifest['visible_files']
    files[files.keys.first]['content'] += "\n# change"
    saver.kata_ran_tests(id, 1, files, 'stdout', 'stderr', 0, ran_summary('red'))
    now_index = saver.kata_events(id).last['index']
    result = differ.diff_summary(id, 0, now_index)
    assert_equal 1, result.count { |d| d['type'] != 'unchanged' }
  end

  test 'F7C4D3',
  'diff_lines() returns the changed file' do
    manifest = starter_manifest
    id = saver.kata_create(manifest)
    files = manifest['visible_files']
    files[files.keys.first]['content'] += "\n# change"
    saver.kata_ran_tests(id, 1, files, 'stdout', 'stderr', 0, ran_summary('red'))
    now_index = saver.kata_events(id).last['index']
    result = differ.diff_lines(id, 0, now_index)
    assert_equal 1, result.count { |d| d['type'] != 'unchanged' }
  end

end
