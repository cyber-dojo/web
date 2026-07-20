
module TestExternalHelpers # mix-in

  module_function

  include Externals

  def setup
    @config = {
      'RUNNER'    => ENV['CYBER_DOJO_RUNNER_CLASS'],
      'SAVER'     => ENV['CYBER_DOJO_SAVER_CLASS'],
      'SPOOLER'   => ENV['CYBER_DOJO_SPOOLER_CLASS'],
      'HTTP'      => ENV['CYBER_DOJO_HTTP_CLASS'],
    }
  end

  def teardown
    ENV['CYBER_DOJO_RUNNER_CLASS']  = @config['RUNNER']
    ENV['CYBER_DOJO_SAVER_CLASS']   = @config['SAVER']
    ENV['CYBER_DOJO_SPOOLER_CLASS'] = @config['SPOOLER']
    ENV['CYBER_DOJO_HTTP_CLASS']    = @config['HTTP']
  end

  # - - - - - - - - - - - - - - - - - - -
  # Seed a committed saver event through the async write path the app uses:
  # POST the write to the spooler, whose drainer forwards it to saver. The
  # spooler acks before saver has committed, so poll saver's committed events
  # until this write's light has drained (matched by the unique tab_seq it
  # carries, plus its colour, so the underneath file_edit sibling that shares the
  # tab_seq is not mistaken for it). Returns saver's committed events.

  def kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    spooler.kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    wait_until_drained(id, tab_seq, summary['colour'])
  end

  def kata_revert(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    spooler.kata_reverted(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    wait_until_drained(id, tab_seq, summary['colour'])
  end

  def wait_until_drained(id, tab_seq, colour, attempts: 200, sleep_seconds: 0.05)
    attempts.times do
      events = saver.kata_events(id)
      drained = events.any? do |event|
        # tab_seq compared as strings: a write POSTed as a form field reaches
        # saver as a string, while a write passed straight to the client is an
        # integer - both must match the value the caller holds.
        event['tab_seq'].to_s == tab_seq.to_s && event['colour'] == colour
      end
      return events if drained
      sleep(sleep_seconds)
    end
    fail "spooler write (tab_seq=#{tab_seq}, colour=#{colour}) never drained to saver for kata #{id}"
  end

  # Soft, bounded wait keyed on tab_seq alone, for a POST whose write may or may
  # not commit (a bad id, or the run_tests rescue path, commits nothing). Returns
  # once the write with this tab_seq has drained to saver, or quietly gives up
  # after the timeout so an intentional no-commit does not hang - the test's own
  # assertions then report any genuine miss.
  def wait_until_committed(id, tab_seq, colour: nil, attempts: 100, sleep_seconds: 0.05)
    return if tab_seq.nil?
    attempts.times do
      committed = saver.kata_events(id).any? do |event|
        event['tab_seq'].to_s == tab_seq.to_s && (colour.nil? || event['colour'] == colour)
      end
      return if committed
      sleep(sleep_seconds)
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_runner_class(name)
    set_class('runner', name)
  end

  def get_class(name)
    key = 'CYBER_DOJO_' + name.upcase + '_CLASS'
    ENV[key]
  end

  def set_class(name, value)
    key = 'CYBER_DOJO_' + name.upcase + '_CLASS'
    ENV[key] = value
  end

end
