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
    in_kata(:stateless) { |kata|
      as_lion_in(kata) {
        assert_spied_run_stateless(kata)
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74B',
  'stateful run() delegates to stateful runner' do
    in_kata(:stateful) { |kata|
      as_lion_in(kata) {
        assert_spied_run_stateful(kata)
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74C',
  'processful run() delegates to processful runner' do
    in_kata(:processful) { |kata|
      as_lion_in(kata) {
        assert_spied_run_processful(kata)
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '812',
  'run() is red' do
    kata = make_language_kata({
      'display_name' => 'C (gcc), assert'
    })
    runner.avatar_new(kata.image_name, kata.id, lion, starting_files)
    begin
      stdout,stderr,status,colour = runner.run(*run_args(kata))
      assert stderr.include?('[makefile:14: test.output] Aborted'), stderr
      assert stderr.include?('Assertion failed: answer() == 42'), stderr
      assert_equal 2, status
      assert_equal 'red', colour
    ensure
      runner.avatar_old(kata.image_name, kata.id, lion)
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  private # = = = = = = = = = = = = = = = = = = =

  def in_kata(runner_choice, &block)
    display_name = {
        stateless: 'Python, unittest',
         stateful: 'C (gcc), assert',
       processful: 'Python, py.test'
    }[runner_choice]

    kata = make_language_kata({ 'display_name' => display_name })
    begin
      assert_equal runner_choice.to_s, kata.runner_choice
      block.call(kata)
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def as_lion_in(kata, &block)
    starting_files = kata.visible_files
    runner.avatar_new(kata.image_name, kata.id, lion, starting_files)
    begin
      block.call
    ensure
      runner.avatar_old(kata.image_name, kata.id, lion)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def run_args(kata)
    starting_files = kata.visible_files
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
    args
  end

  def expected_run_args(kata)
    {
      :image_name        => kata.image_name,
      :kata_id           => kata.id,
      :avatar_name       => lion,
      :new_files         => {},
      :deleted_files     => {},
      :changed_files     => kata.visible_files,
      :unchanged_files   => {},
      :max_seconds       => (max_seconds = 10)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_spied_run_stateless(kata)
    http_spied_run(kata) {
      assert_equal [
        stateful_runner_name = 'runner_stateless',
        stateful_runner_port = 4597,
        'run_cyber_dojo_sh',
        expected_run_args(kata)
      ], http.spied[0]
    }
  end

  def assert_spied_run_stateful(kata)
    http_spied_run(kata) {
      assert_equal [
        stateful_runner_name = 'runner_stateful',
        stateful_runner_port = 4557,
        'run_cyber_dojo_sh',
        expected_run_args(kata)
      ], http.spied[0]
    }
  end

  def assert_spied_run_processful(kata)
    http_spied_run(kata) {
      assert_equal [
        stateful_runner_name = 'runner_processful',
        stateful_runner_port = 4547,
        'run_cyber_dojo_sh',
        expected_run_args(kata)
      ], http.spied[0]
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def http_spied_run(kata, &block)
    saved_http = @http
    @http = HttpSpy.new(nil)
    begin
      runner.run(*run_args(kata))
      block.call
    ensure
      @http = saved_http
    end
  end

end
