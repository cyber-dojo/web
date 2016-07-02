
module Runner # mix-in

  module_function

  def output_or_timed_out(output, exit_status, max_seconds)
    exit_status != timed_out ? truncated(cleaned(output)) : did_not_complete(max_seconds)
  end

  def did_not_complete(max_seconds)
    "Unable to complete the tests in #{max_seconds} seconds.\n" +
    "Is there an accidental infinite loop?\n" +
    "Is the server very busy?\n" +
    "Please try again."
  end

  def timed_out
    (timeout = 128) + (kill = 9)
  end

  include StringCleaner
  include StringTruncater
  include StderrRedirect

end
