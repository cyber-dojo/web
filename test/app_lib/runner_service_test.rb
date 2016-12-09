#!/bin/bash ../test_wrapper.sh

require_relative './app_lib_test_base'

class RunnerServiceTest < AppLibTestBase

  def setup
    super
    set_storer_class('FakeStorer')
  end

  def setup_runner_class
    set_runner_class('RunnerService')
  end

  #------------------------------------------------------------------

  test '2BDAD808',
  'smoke test runner-service' do
    refute runner.pulled? 'cyberdojo/non_existant'
    image_name = 'cyberdojofoundation/gcc_assert'
    runner.pull image_name
    kata_id = '2BDAD80801'
    runner.new_kata(image_name, kata_id)
    runner.new_avatar(image_name, kata_id, lion, starting_files)
    args = []
    args << image_name
    args << kata_id
    args << lion
    args << (deleted_filenames = [])
    args << starting_files
    args << (max_seconds = runner.max_seconds)
    begin
      stdout,stderr,status = runner.run(*args)
      assert stdout.start_with? "makefile:4: recipe for target 'test.output' failed"
      assert stderr.start_with? 'Assertion failed: answer() == 42'
      assert_equal 2, status
    ensure
      runner.old_avatar(kata_id, lion)
      runner.old_kata(kata_id)
    end
  end

end
