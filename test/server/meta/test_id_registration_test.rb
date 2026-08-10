require_relative '../../test_base'

class TestIdRegistrationTest < TestBase

  # A throwaway class carrying the mix-in, so test() defines its method there
  # rather than on a class minitest would run.
  def registrar
    Class.new { include TestHexIdHelpers }
  end

  # test() reads and writes these globals. A meta test drives them and must put
  # them back: Minitest.after_run reads $args when the run ends.
  def with_globals(args, seen_ids)
    old_args, old_seen_ids = $args, $seen_ids
    $args, $seen_ids = args, seen_ids
    yield
  ensure
    $args, $seen_ids = old_args, old_seen_ids
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4Bd21a', %w(
  | test() rejects an empty test-ID, naming the test in the message
  ) do
    with_globals([], []) do
      error = assert_raises(RuntimeError) { registrar.test('', 'some', 'name') {} }
      assert_equal "no test-ID: '',some name", error.message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4Bd21b', %w(
  | test() rejects a test-ID that is not base58
  ) do
    with_globals([], []) do
      error = assert_raises(RuntimeError) { registrar.test('abc!', 'some', 'name') {} }
      assert_equal "bad test-ID: 'abc!',some name", error.message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4Bd21c', %w(
  | test() rejects a test-ID already used by another test
  ) do
    with_globals([], ['7fA23b']) do
      error = assert_raises(RuntimeError) { registrar.test('7fA23b', 'some', 'name') {} }
      assert_equal "duplicate test-ID: '7fA23b',some name", error.message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4Bd21d', %w(
  | test() defines no method for a test whose ID matches none of the
  | tid arguments the run was filtered by
  ) do
    klass = registrar
    with_globals(['ZZZZZ'], []) do
      klass.test('7fA23b', 'some', 'name') {}
    end
    assert_equal [], klass.instance_methods(false)
  end

end
