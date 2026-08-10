require_relative '../test_base'

class TidArgMatchingTest < TestBase

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4Bd22a', %w(
  | check_all_tid_args_matched() raises, naming the unmatched arguments,
  | when a tid argument matched no test-ID
  ) do
    error = assert_raises(RuntimeError) do
      TestBase.check_all_tid_args_matched(['ZZZZZ'], ['7fA23b'])
    end
    expected = "\nthe following test id arguments were *not* found\n[\"ZZZZZ\"]\n"
    assert_equal expected, error.message
  end

end
