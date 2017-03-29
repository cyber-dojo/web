require_relative 'app_lib_test_base'

class RunnerServiceTest < AppLibTestBase

  # These will fail if there is no network connectivity.

  def setup
    super
    set_storer_class('FakeStorer')
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BD23CD3',
  'smoke test runner-service raising' do
    assert_raises { runner.image_pulled?(nil, nil) }
    assert_raises { runner.image_pull(nil, nil) }
    assert_raises { runner.kata_new(nil, nil) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDF808102',
  'smoke test pulling' do
    kata_id = '2BDF808102'
    refute runner.image_pulled? 'cyberdojo/non_existant', kata_id
    image_name = 'cyberdojofoundation/gcc_assert'
    assert runner.image_pull image_name, kata_id
    assert runner.image_pulled? image_name, kata_id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDAD80812',
  'smoke test runner-service colour is red-amber-green traffic-light' do
    image_name = 'cyberdojofoundation/gcc_assert'
    kata_id = '2BDAD80812'
    runner.kata_new(image_name, kata_id)
    runner.avatar_new(image_name, kata_id, lion, starting_files)
    args = []
    args << image_name
    args << kata_id
    args << lion
    args << (deleted_filenames = [])
    args << starting_files
    args << (max_seconds = 10)
    begin
      _stdout,_stderr,_status,colour = runner.run(*args)
      assert_equal 'red', colour
    ensure
      runner.avatar_old(image_name, kata_id, lion)
      runner.kata_old(image_name, kata_id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BDAD80801',
  'smoke test runner-service colour is not nil' do
    image_name = 'cyberdojofoundation/gcc_assert'
    kata_id = '2BDAD80801'
    runner.kata_new(image_name, kata_id)
    runner.avatar_new(image_name, kata_id, lion, starting_files)
    args = []
    args << image_name
    args << kata_id
    args << lion
    args << (deleted_filenames = [])
    args << starting_files
    args << (max_seconds = 10)
    begin
      stdout,stderr,status,colour = runner.run(*args)
      assert stdout.start_with? "makefile:4: recipe for target 'test.output' failed"
      assert stderr.start_with? 'Assertion failed: answer() == 42'
      assert_equal 2, status
      assert_equal 'red', colour
    ensure
      runner.avatar_old(image_name, kata_id, lion)
      runner.kata_old(image_name, kata_id)
    end
  end

end
