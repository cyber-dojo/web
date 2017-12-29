require_relative 'app_services_test_base'

class RunnerServiceTest < AppServicesTestBase

  def self.hex_prefix
    '2BDF80'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_storer_class('StorerFake')
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '102',
  'image_pulled?' do
    kata = make_language_kata
    refute runner.image_pulled?('cyberdojo/non_existant', kata.id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '103',
  'image_pull' do
    kata = make_language_kata
    refute runner.image_pull('cyberdojo/non_existant', kata.id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74A',
  'stateless run() delegates to stateless runner' do
    in_kata_stateless { |kata|
      as_lion(kata) {
        runner.run(*run_args(kata))
        assert_spied_run_stateless(kata)
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74B',
  'stateful run() delegates to stateful runner' do
    in_kata_stateful { |kata|
      as_lion(kata) {
        runner.run(*run_args(kata))
        assert_spied_run_stateful(kata)
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74C',
  'processful run() delegates to processful runner' do
    in_kata_processful { |kata|
      as_lion(kata) {
        runner.run(*run_args(kata))
        assert_spied_run_processful(kata)
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '812',
  'runner-service colour is red-amber-green traffic-light' do
    kata = make_language_kata({
      'display_name' => 'C (gcc), assert'
    })
    runner.avatar_new(kata.image_name, kata.id, lion, starting_files)
    args = []
    args << kata.image_name
    args << kata.id
    args << lion
    args << (max_seconds = 10)
    args << (delta = {
      :deleted   => [],
      :new       => [],
      :changed   => starting_files.keys,
      :unchanged => []
    })
    args << starting_files
    begin
      stdout,stderr,status,colour = runner.run(*args)
      assert stderr.include?('[makefile:4: test.output] Aborted'), stderr
      assert stderr.include?('Assertion failed: answer() == 42'), stderr
      assert_equal 2, status
      assert_equal 'red', colour
    ensure
      runner.avatar_old(kata.image_name, kata.id, lion)
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  private # = = = = = = = = = = = = = = = = = = =

  def in_kata_stateless
    kata = make_language_kata({ 'display_name' => 'Python, unittest' })
    assert_equal 'stateless', kata.runner_choice
    begin
      yield kata
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def in_kata_stateful
    kata = make_language_kata({ 'display_name' => 'C (gcc), assert' })
    assert_equal 'stateful', kata.runner_choice
    begin
      yield kata
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def in_kata_processful
    kata = make_language_kata({ 'display_name' => 'Python, py.test' })
    assert_equal 'processful', kata.runner_choice
    begin
      yield kata
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def as_lion(kata)
    starting_files = kata.visible_files
    runner.avatar_new(kata.image_name, kata.id, lion, starting_files)
    http = @http
    @http = HttpSpy.new(nil)
    begin
      yield
    ensure
      @http = http
      runner.avatar_old(kata.image_name, kata.id, lion)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def run_args(kata)
    args = []
    args << kata.image_name
    args << kata.id
    args << lion
    args << (max_seconds = 10)
    args << (delta = { :deleted => ['instructions'], :new => [], :changed => {} })
    args << (files = {})
    args
  end

  def expected_run_args(kata)
    {
      :image_name        => kata.image_name,
      :kata_id           => kata.id,
      :avatar_name       => lion,
      :new_files         => {},
      :deleted_files     => { 'instructions' => '' },
      :changed_files     => {},
      :unchanged_files   => {},
      :max_seconds       => (max_seconds = 10)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_spied_run_stateless(kata)
    assert_equal [
      stateful_runner_name = 'runner_stateless',
      stateful_runner_port = 4597,
      'run_cyber_dojo_sh',
      expected_run_args(kata)
    ], @http.spied[0]
  end

  def assert_spied_run_stateful(kata)
    assert_equal [
      stateful_runner_name = 'runner_stateful',
      stateful_runner_port = 4557,
      'run_cyber_dojo_sh',
      expected_run_args(kata)
    ], @http.spied[0]
  end

  def assert_spied_run_processful(kata)
    assert_equal [
      stateful_runner_name = 'runner_processful',
      stateful_runner_port = 4547,
      'run_cyber_dojo_sh',
      expected_run_args(kata)
    ], @http.spied[0]
  end

end
