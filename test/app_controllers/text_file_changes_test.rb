require_relative 'app_controller_test_base'

class TextFileChangesTest  < AppControllerTestBase

  def self.hex_prefix
    '8q5'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC', %w(
  when a test-event deletes an existing text file
  then the model records it
  ) do
    filename = 'readme.txt'
    id = in_kata do |kata|
      id = kata.id
      assert kata.event(-1)['files'].keys.include?(filename)
      change_file('cyber-dojo.sh', "rm #{filename}")
      post_run_tests
      kata.id
    end
    kata = katas[id]
    files = kata.event(-1)['files']
    filenames = files.keys.sort
    refute filenames.include?(filename), filenames
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DD', %w(
  when a test-event creates a new text file
  then the model records it
  ) do
    filename = 'wibble.txt'
    id = in_kata do |kata|
      change_file('cyber-dojo.sh', "echo -n Hello > #{filename}")
      post_run_tests
      kata.id
    end
    kata = katas[id]
    files = kata.event(-1)['files']
    filenames = files.keys.sort
    assert filenames.include?(filename), filenames
    assert_equal 'Hello', files[filename]['content']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DE', %w(
  when a test-event changes a regular text-file
  then the model records it ) do
    filename = 'readme.txt'
    id = in_kata do |kata|
      assert kata.event(-1)['files'].keys.include?(filename)
      change_file('cyber-dojo.sh', "echo -n Hello > #{filename}")
      post_run_tests
      kata.id
    end
    kata = katas[id]
    files = kata.event(-1)['files']
    filenames = files.keys.sort
    assert filenames.include?(filename), filenames
    assert_equal 'Hello', files[filename]['content']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '736', %w(
  when cyber-dojo.sh creates a new text file called stdout
  then the model records it separately to the stdout 'output' file
  ) do
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

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '737', %w(
  when cyber-dojo.sh creates a new text file called stderr
  then the model records it separately to the stderr 'output' file
  ) do
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

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '738', %w(
  when a test-event creates a new text file called status
  then the model does _not_ record it because it already records
  stdout,stderr,status as 'output' files
  ) do
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

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A28', %w(
  generated files are returned from runner
  unless cyber-dojo.sh explicitly deletes them ) do
    generated_filename = 'xxxx.txt'
    id = in_kata do |kata|
      change_file('cyber-dojo.sh', "cat xxxx > #{generated_filename}")
      post_run_tests
      kata.id
    end
    kata = katas[id]
    filenames = kata.event(-1)['files'].keys
    assert filenames.include?(generated_filename), filenames
  end

end
