require_relative 'lib_test_base'

class LogStdoutTest < LibTestBase

  test '1B6962',
  '<< writes to stdout with automatic trailing newline' do
    log = LogStdout.new(nil)
    written = with_captured_stdout {
      log << "Hello world"
    }
    assert_equal "Hello world\n", written
  end

  private

  def with_captured_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('','w')
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

end
