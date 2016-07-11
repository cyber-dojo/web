
# Each GET/POST is serviced through the rails router in a new thread which creates
# a new dojo object and thus a new shell object (from one created in a test).
# Mock expectations that a test sets up in one object have to be saved to disk so they
# can be retrieved from a different object.

class MockHostShell

  def initialize(_dojo)
    test_id =  ENV['CYBER_DOJO_TEST_ID']
    @filename = Dir.tmpdir + '/cyber-dojo-' + test_id + '_mock_host_shell.json'
    write([]) unless File.file?(@filename)
  end

  def teardown
    mocks = read
    fail "#{filename}: uncalled mock exceptations(#{mocks})" unless mocks == []
    File.delete(filename)
  end

  def mock_cd_exec(path, commands, output, exit_status)
    append_expectation({
             call: 'cd_exec',
             path: path,
         commands: commands,
           output: output,
      exit_status: exit_status
    })
  end

  def mock_exec(commands, output, exit_status)
    append_expectation({
             call: 'exec',
         commands: commands,
           output: output,
      exit_status: exit_status
    })
  end

  def cd_exec(path, *commands)
    mocks = read
    raise "cd_exec: no mock for (#{path},#{commands})" if mocks == []
    mock = mocks.shift
    raise "cd_exec: mock is for #{mock['call']}" unless mock['call'] == 'cd_exec'
    if [path,commands] != [mock['path'],mock['commands']]
      complain('cd_exec', "#{mock['path']}, #{mock['commands']}", "#{path}, #{commands}")
    end
    write(mocks)
    [mock['output'], mock['exit_status']]
  end

  def exec(*commands)
    mocks = read
    raise "exec: no mock for (#{commands})" if mocks == []
    mock = mocks.shift
    raise "exec: mock is for #{mock['call']}" unless mock['call'] == 'exec'
    if commands != mock['commands']
      complain('exec', "#{mock['commands']}", "#{commands}")
    end
    write(mocks)
    [mock['output'], mock['exit_status']]
  end

  private

  def append_expectation(expectation)
    expectations = read
    write(expectations << expectation)
  end

  def read
    JSON.parse(IO.read(filename))
  end

  def write(expectations)
    IO.write(filename, JSON.unparse(expectations))
  end

  def filename
    @filename
  end

  def complain(cmd, expected, actual)
    raise [
      self.class.name,
      "expected: #{cmd}(#{expected})",
      "  actual: #{cmd}(#{actual})"
    ].join("\n") + "\n"
  end

end
