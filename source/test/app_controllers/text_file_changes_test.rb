require_relative 'app_controller_test_base'

class TextFileChangesTest  < AppControllerTestBase

  def self.hex_prefix
    '8q5'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC', %w(
  |when cyber-dojo.sh deletes an existing text file
  |then the saver does NOT record it
  |because the illusion is the [test] is running in the browser
  |see also https://github.com/cyber-dojo/cyber-dojo/issues/7
  ) do
    with_runner_class('RunnerStub') do
      filename = 'readme.txt'
      in_kata do |kata|
        assert kata.event(-1)['files'].keys.include?(filename)
        runner.stub_run({deleted: ['readme.txt']})
        post_run_tests
        files = kata.event(-1)['files']
        filenames = files.keys.sort
        assert filenames.include?(filename), filenames
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DD', %w(
  |given cyber-dojo.sh contains a command to create new text file
  |when the test-event occurs
  |then the saver records the new file
  ) do
    with_runner_class('RunnerService') do
      filename = 'wibble.txt'
      in_kata do |kata|
        change_file('cyber-dojo.sh', "echo -n Hello > #{filename}")
        post_run_tests
        files = kata.event(-1)['files']
        filenames = files.keys.sort
        assert filenames.include?(filename), filenames
        assert_equal 'Hello', files[filename]['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DE', %w(
  |given cyber-dojo.sh contains a command to change an existing text file
  |when the test-event occurs
  |then the saver records the changed file
  ) do
    with_runner_class('RunnerService') do
      filename = 'readme.txt'
      in_kata do |kata|
        assert kata.event(-1)['files'].keys.include?(filename)
        change_file('cyber-dojo.sh', "echo -n Hello > #{filename}")
        post_run_tests
        files = kata.event(-1)['files']
        filenames = files.keys.sort
        assert filenames.include?(filename), filenames
        assert_equal 'Hello', files[filename]['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '736', %w(
  |given cyber-dojo.sh contains a command to create a new text file called stdout
  |when the test-event occurs
  |then the saver records it separately to the standard stdout stream
  ) do
    with_runner_class('RunnerService') do
      in_kata do |kata|
        script = [
          "echo -n Hello",
          "echo -n Bonjour > stdout"
        ].join("\n")
        change_file('cyber-dojo.sh', script)
        post_run_tests

        last = kata.event(-1)
        assert last['files'].keys.include?('stdout')
        assert_equal 'Bonjour', last['files']['stdout']['content']
        assert_equal 'Hello', last['stdout']['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '737', %w(
  |given cyber-dojo.sh contains a command to create new text file called 'stderr'
  |when the test-event occurs
  |then the saver records it separately to the standard 'stderr' stream
  ) do
    with_runner_class('RunnerService') do
      in_kata do |kata|
        script = [
          ">&2 echo -n Hello2",
          "echo -n Bonjour2 > stderr"
        ].join("\n")
        change_file('cyber-dojo.sh', script)
        post_run_tests

        last = kata.event(-1)
        assert last['files'].keys.include?('stderr')
        assert_equal 'Bonjour2', last['files']['stderr']['content']
        assert_equal 'Hello2', last['stderr']['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '738', %w(
  |given cyber-dojo.sh contains a command to create a new text file called 'status'
  |when the test-event occurs
  |then the saver does record it
  |and keeps it separate from the file called 'status' in the multiplex
  ) do
    with_runner_class('RunnerService') do
      in_kata do |kata|
        script = [
          "echo -n Bonjour3 > status",
          "exit 42"
        ].join("\n")
        change_file('cyber-dojo.sh', script)
        post_run_tests

        last = kata.event(-1)
        assert last['files'].keys.include?('status')
        assert_equal 'Bonjour3', last['files']['status']['content']
        assert_equal '42', last['status']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A28', %w(
  generated files are returned from runner
  unless cyber-dojo.sh explicitly deletes them
  ) do
    with_runner_class('RunnerService') do
      generated_filename = 'xxxx.txt'
      in_kata do |kata|
        change_file('cyber-dojo.sh', "cat xxxx > #{generated_filename}")
        post_run_tests
        filenames = kata.event(-1)['files'].keys
        assert filenames.include?(generated_filename), filenames
      end
    end
  end

end
