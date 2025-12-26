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
    existing_filename = 'readme.txt'
    with_runner_class('RunnerStub') do
      in_kata do |kata|
        assert kata.event(-1)['files'].keys.include?(existing_filename)
        runner.stub_run({deleted: [existing_filename]})
        post_run_tests
        files = kata.event(-1)['files']
        filenames = files.keys.sort
        assert filenames.include?(existing_filename), filenames
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DD', %w(
  |given cyber-dojo.sh contains a command to create new text file
  |then the saver records the new file
  ) do
    new_filename = 'wibble.txt'
    new_content = 'Hello world'
    with_runner_class('RunnerStub') do
      in_kata do |kata|
        refute kata.event(-1)['files'].keys.include?(new_filename)
        runner.stub_run({created: {new_filename => content(new_content)}})
        post_run_tests
        files = kata.event(-1)['files']
        filenames = files.keys.sort
        assert filenames.include?(new_filename), filenames
        assert_equal new_content, files[new_filename]['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DE', %w(
  |given cyber-dojo.sh contains a command to change an existing text file
  |then the saver records the changed file
  ) do
    existing_filename = 'readme.txt'
    changed_content = 'Hello world'
    with_runner_class('RunnerStub') do
      in_kata do |kata|
        assert kata.event(-1)['files'].keys.include?(existing_filename)
        runner.stub_run({changed: {existing_filename => content(changed_content)}})
        post_run_tests
        files = kata.event(-1)['files']
        filenames = files.keys.sort
        assert filenames.include?(existing_filename), filenames
        assert_equal changed_content, files[existing_filename]['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '736', %w(
  |given cyber-dojo.sh contains a command to create a new text file called stdout
  |then the saver records it
  |but does not confuse it with the standard stdout stream
  ) do
    new_filename = 'stdout'
    new_content = 'Bonjour'
    stdout_content = 'Hello'
    with_runner_class('RunnerStub') do
      in_kata do |kata|
        runner.stub_run({
          stdout: stdout_content,
          created: {new_filename => content(new_content)}
        })
        post_run_tests

        last = kata.event(-1)
        assert last['files'].keys.include?('stdout')
        assert_equal new_content, last['files']['stdout']['content']
        assert_equal stdout_content, last['stdout']['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '737', %w(
  |given cyber-dojo.sh contains a command to create new text file called 'stderr'
  |then the saver records it 
  |but does not confuse it with the standard stdout stream
  ) do
    new_filename = 'stderr'
    new_content = 'Bonjour2'
    stderr_content = 'Hello2'
    with_runner_class('RunnerStub') do
      in_kata do |kata|
        runner.stub_run({
          stderr: stderr_content,
          created: {new_filename => content(new_content)}
        })
        post_run_tests

        last = kata.event(-1)
        assert last['files'].keys.include?('stderr')
        assert_equal new_content, last['files']['stderr']['content']
        assert_equal stderr_content, last['stderr']['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '738', %w(
  |given cyber-dojo.sh contains a command to create a new text file called 'status'
  |then the saver does record it
  |but does not confuse it with the standard status
  ) do
    new_filename = 'status'
    new_content = 'Bonjour3'
    status_value = '42'
    with_runner_class('RunnerStub') do
      in_kata do |kata|
        runner.stub_run({
          status: status_value,
          created: {new_filename => content(new_content)}
        })
        post_run_tests

        last = kata.event(-1)
        assert last['files'].keys.include?('status')
        assert_equal new_content, last['files']['status']['content']
        assert_equal status_value, last['status']
      end
    end
  end

end
