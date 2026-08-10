require_relative '../../test_base'

class SpoolerDrainWaitTest < TestBase

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4Bd23a', %w(
  | wait_until_drained() fails, naming the write it waited for, when no
  | committed event matches within the attempts it was given
  ) do
    in_new_kata do |kata|
      error = assert_raises(RuntimeError) do
        wait_until_drained(kata.id, 999999, 'green', attempts: 1, sleep_seconds: 0)
      end
      expected = "spooler write (tab_seq=999999, colour=green) never drained " \
                 "to saver for kata #{kata.id}"
      assert_equal expected, error.message
    end
  end

end
