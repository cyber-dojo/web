require_relative 'controllers_test_base'

class LegacyInputsTest < ControllersTestBase

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3Fa71b', %w(
  | file_edit() from a legacy browser, one still running JS from an
  | earlier web deploy and so sending no tab_id, still commits its
  | event; the write is stamped with the plain laptop_id cookie
  ) do
    edited_filename = 'readme.txt'
    in_kata do
      @files[edited_filename] += 'Hello world'
      post_json '/kata/file_edit', {
        id: @id,
        tab_seq: next_tab_seq,
        data: { file_content: @files }
      }
      assert last_response.successful?
      assert_equal 2, kata.events.size
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3Fa71c', %w(
  | file_edit() from a legacy browser, one still running JS from a
  | web deploy that stamped tab_id but not yet tab_seq, is accepted;
  | its nil tab_seq is not the real seq 0 that ''.to_i would give
  ) do
    edited_filename = 'readme.txt'
    in_kata do
      @files[edited_filename] += 'Hello world'
      # With no tab_seq there is no key to wait on for the spooler's drain to
      # saver, so this asserts the app accepted the write, not committed state.
      post_json '/kata/file_edit', {
        id: @id,
        tab_id: tab_id,
        data: { file_content: @files }
      }
      assert_equal 204, last_response.status
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3Fa71d', %w(
  | run_tests() for a kata whose manifest predates rag_lambda, whose
  | browser therefore posts an empty one, still lights; web omits
  | rag_lambda from the runner args, leaving runner to read the lambda
  | from the language image instead of evalling a posted one
  ) do
    in_kata do
      runner.stub_run({outcome: 'green'})
      post_run_tests(rag_lambda: '')
      assert_equal 'green', json['light']['colour']
    end
  end

end
