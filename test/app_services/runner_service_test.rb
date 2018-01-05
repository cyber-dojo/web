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
    in_kata {
      refute runner.image_pulled?('cyberdojo/non_existant', kata_id)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '103',
  'image_pull' do
    in_kata {
      refute runner.image_pull('cyberdojo/non_existant', kata_id)
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74A',
  'stateless run() delegates to stateless runner' do
    in_kata(:stateless) {
      as_lion {
        assert_spied_run_stateless
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74B',
  'stateful run() delegates to stateful runner' do
    in_kata(:stateful) {
      as_lion {
        assert_spied_run_stateful
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74C',
  'processful run() delegates to processful runner' do
    in_kata(:processful) {
      as_lion {
        assert_spied_run_processful
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '812',
  'run() is red' do
    in_kata(:stateful) {
      as_lion {
        _stdout,stderr,status,colour = runner.run(*run_args)
        assert stderr.include?('[makefile:13: test.output] Aborted'), stderr
        assert stderr.include?('Assertion failed: answer() == 42'), stderr
        assert_equal 2, status
        assert_equal 'red', colour
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC',
  'deleting a file' do
    in_kata(:stateless) {
      as_lion {
        starting_files = kata.visible_files
        starting_files.delete('instructions')
        starting_files['cyber-dojo.sh'] = 'ls -al'
        args = []
        args << kata.image_name
        args << kata.id
        args << 'lion'
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
    }
  end

  private # = = = = = = = = = = = = = = = = = = =

  def in_kata(runner_choice = :stateless, &block)
    display_name = {
        stateless: 'Python, unittest',
         stateful: 'C (gcc), assert',
       processful: 'Python, py.test'
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
      assert_equal [ 'runner_stateless', 4597,
        'run_cyber_dojo_sh', expected_run_args
      ], http.spied[0]
    }
  end

  def assert_spied_run_stateful
    http_spied_run {
      assert_equal [ 'runner_stateful', 4557,
        'run_cyber_dojo_sh', expected_run_args
      ], http.spied[0]
    }
  end

  def assert_spied_run_processful
    http_spied_run {
      assert_equal [ 'runner_processful', 4547,
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
