require_relative 'app_lib_test_base'

class SmokeTest < AppLibTestBase

  def self.hex_prefix
    '98255E'
  end

  def hex_setup
    set_storer_class('StorerService')
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -
  # runner
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test 'CD3',
  'smoke test runner-service raising' do
    set_storer_class('StorerFake')
    kata = make_language_kata
    runner.kata_old(kata.image_name, kata.id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test '102',
  'smoke test image_pulled?' do
    kata = make_language_kata({
      'display_name' => 'Python, unittest'
    })
    assert kata.runner_choice == 'stateless' # no need to do runner.kata_old
    refute runner.image_pulled? 'cyberdojo/non_existant', kata.id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test '812',
  'smoke test runner-service colour is red-amber-green traffic-light' do
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

end
