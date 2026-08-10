require_relative 'services_test_base'

class CaptureStdoutStderrTest < ServicesTestBase

  test 'Cp7a41', %w(
  | capture_stdout_stderr must capture via the per-thread stream WITHOUT
  | swapping the process-global $stdout/$stderr.
  | Swapping the global makes the helper unsafe under concurrent test
  | execution: a write from another thread lands in this thread's captured
  | buffer, bleeding one test's output into another's assertions.
  ) do
    outer_stdout = $stdout
    outer_stderr = $stderr
    inner_stdout = nil
    inner_stderr = nil
    captured_stdout, captured_stderr = capture_stdout_stderr do
      inner_stdout = $stdout
      inner_stderr = $stderr
      Thread.current[:stdout_stream].print('hello-out')
      Thread.current[:stderr_stream].print('hello-err')
    end
    # capture still works, via the per-thread stream
    assert_equal 'hello-out', captured_stdout, :captured_stdout
    assert_equal 'hello-err', captured_stderr, :captured_stderr
    # but the process-global streams must be left untouched (thread-safety)
    assert_same outer_stdout, inner_stdout, :global_stdout_not_swapped
    assert_same outer_stderr, inner_stderr, :global_stderr_not_swapped
  end

end
