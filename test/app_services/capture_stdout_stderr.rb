# frozen_string_literal: false # [1]

module CaptureStdoutStderr

  def capture_stdout_stderr
    begin
      uncaptured_stdout = $stdout
      uncaptured_stderr = $stderr
      captured_stdout = StringIO.new('', 'w') # [1]
      captured_stderr = StringIO.new('', 'w') # [1]
      $stdout = captured_stdout
      $stderr = captured_stderr
      yield uncaptured_stdout, uncaptured_stderr
      [ $stdout.string, $stderr.string ]
    ensure
      $stdout = uncaptured_stdout
      $stderr = uncaptured_stderr
    end
  end

end
