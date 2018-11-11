require_relative 'app_services_test_base'

class RunnerServiceTest < AppServicesTestBase

  def self.hex_prefix
    '2BD'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_saver_class('SaverService')
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74F',
  'smoke test runner.sha' do
    assert_sha(runner.sha('stateless'))
    assert_sha(runner.sha('stateful'))
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74A',
  'stateless run() delegates to stateless runner' do
    in_kata(:stateless) {
      assert_spied_run_stateless
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74B',
  'stateful run() delegates to stateful runner' do
    in_kata(:stateful) {
      assert_spied_run_stateful
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '812',
  'run() is red' do
    in_kata(:stateless) {
      result = runner.run_cyber_dojo_sh(*run_args)
      assert result['stdout'].include?('Expected: 42'), result
      assert result['stdout'].include?('  Actual: 54'), result
      assert_equal '', result['stderr'], result
      assert_equal 1, result['status'], result
      assert_equal 'red', result['colour'], result
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC',
  'deleting a file' do
    in_kata(:stateless) {
      files = kata.files
      readme = files.delete('readme.txt')
      files['cyber-dojo.sh'] = 'ls -al'
      args = []
      args << kata.manifest.runner_choice
      args << kata.manifest.image_name
      args << kata.id
      args << {} # new_files
      args << { 'readme.txt' => readme } # deleted_files
      args << { 'cyber-dojo.sh' => files['cyber-dojo.sh'] } # changed_files
      args << files # unchanged_files
      args << (max_seconds = 10)
      result = runner.run_cyber_dojo_sh(*args)
      assert result['stdout'].include?('cyber-dojo.sh'), result
      refute result['stdout'].include?('readme.txt'), result
      assert_equal '', result['stderr'], result
      assert_equal 0, result['status'], result
      assert_equal 'amber', result['colour'], result
    }
  end

  private # = = = = = = = = = = = = = = = = = = =

  def run_args
    args = []
    args << kata.manifest.runner_choice
    args << kata.manifest.image_name
    args << kata.id
    args << (new_files={})
    args << (deleted_files={})
    args << (changed_files=kata.files)
    args << (unchanged_files={})
    args << (max_seconds = 10)
    args
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def expected_run_args
    {
      :image_name      => kata.manifest.image_name,
      :id              => kata.id,
      :new_files       => {},
      :deleted_files   => {},
      :changed_files   => kata.files,
      :unchanged_files => {},
      :max_seconds     => (max_seconds = 10)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_spied_run_stateless
    http_spied_run {
      assert_equal [ 'runner-stateless', 4597,
        'run_cyber_dojo_sh', expected_run_args
      ], @spy.spied[0]
    }
  end

  def assert_spied_run_stateful
    http_spied_run {
      assert_equal [ 'runner-stateful', 4557,
        'run_cyber_dojo_sh', expected_run_args
      ], @spy.spied[0]
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def http_spied_run(&block)
    args = run_args
    saved_http = @http
    @http = @spy = HttpSpy.new(nil)
    begin
      runner.run_cyber_dojo_sh(*args)
      @http = saved_http
      block.call
    ensure
      @http = saved_http
    end
  end

end
