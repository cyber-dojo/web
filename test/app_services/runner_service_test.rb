require_relative 'app_services_test_base'

class RunnerServiceTest < AppServicesTestBase

  def self.hex_prefix
    '2BD'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_storer_class('StorerFake')
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
    in_kata(:stateful) {
      stdout,stderr,status,colour = runner.run(*run_args)
      assert stdout.include?('expected: 42'), stdout
      assert stdout.include?('got: 54'), stdout
      assert_equal '', stderr
      assert_equal 1, status
      assert_equal 'red', colour
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC',
  'deleting a file' do
    in_kata(:stateless) {
      starting_files = kata.visible_files
      starting_files.delete('instructions')
      starting_files['cyber-dojo.sh'] = 'ls -al'
      args = []
      args << kata.manifest.runner_choice
      args << kata.manifest.image_name
      args << kata.id
      args << (max_seconds = 10)
      args << (delta = {
        :deleted   => [ 'instructions' ],
        :new       => [],
        :changed   => [ 'cyber-dojo.sh' ],
        :unchanged => starting_files.keys - ['cyber-dojo.sh']
      })
      args << starting_files
      args
      stdout,stderr,status,colour = runner.run(*args)
      assert stdout.include?('cyber-dojo.sh')
      refute stdout.include?('instructions')
      assert_equal '', stderr
      assert_equal 0, status
      assert_equal 'amber', colour
    }
  end

  private # = = = = = = = = = = = = = = = = = = =

=begin
  def in_kata(runner_choice = :stateless, &block)
    display_name = {
       stateless: 'Ruby, MiniTest',
        stateful: 'Ruby, RSpec'
      #processful: 'Ruby, Test::Unit'
    }[runner_choice]
    refute_nil display_name, runner_choice
    make_language_kata({ 'display_name' => display_name })
    begin
      assert_equal runner_choice.to_s, kata.runner_choice
      block.call
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def as_lion(&block)
    starting_files = kata.visible_files
    runner.avatar_new(kata.image_name, kata.id, 'lion', starting_files)
    begin
      block.call
    ensure
      runner.avatar_old(kata.image_name, kata.id, 'lion')
    end
  end
=end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def run_args
    starting_files = kata.visible_files
    args = []
    args << kata.image_name
    args << kata.id
    args << 'lion'
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

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def expected_run_args
    {
      :image_name        => kata.image_name,
      :kata_id           => kata.id,
      :avatar_name       => 'lion',
      :new_files         => {},
      :deleted_files     => {},
      :changed_files     => kata.visible_files,
      :unchanged_files   => {},
      :max_seconds       => (max_seconds = 10)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_spied_run_stateless
    http_spied_run {
      assert_equal [ 'runner-stateless', 4597,
        'run_cyber_dojo_sh', expected_run_args
      ], http.spied[0]
    }
  end

  def assert_spied_run_stateful
    http_spied_run {
      assert_equal [ 'runner-stateful', 4557,
        'run_cyber_dojo_sh', expected_run_args
      ], http.spied[0]
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def http_spied_run(&block)
    saved_http = @http
    @http = HttpSpy.new(nil)
    begin
      runner.run(*run_args)
      block.call
    ensure
      @http = saved_http
    end
  end

end
