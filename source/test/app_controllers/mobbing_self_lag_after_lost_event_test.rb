require_relative 'app_controller_test_base'

class MobbingSelfLagAfterLostEventTest < AppControllerTestBase

  test 'sLg7A1', %w(
  | A solo user on an unshared kata can lose the response to an inter-test
  | file event: the saver commits it and advances the head, but the browser's
  | fetch aborts so it never applies the returned index and its own index stays
  | stale. The next [test] is sent at that stale index, with NO resync. Because
  | every event the browser missed was written by this same laptop, the saver
  | accepts the write as self-lag (placing it at head + 1) instead of rejecting
  | it - so the solo user gets NO false out-of-sync (mobbing) dialog.
  ) do
    in_kata do |kata|
      # Browser is synced: the only event is the index-0 created event,
      # so the next index to write is 1.
      stale_index = @index
      assert_equal 1, stale_index

      # The browser fires an inter-test file_create. The saver commits it
      # (advancing the head) but the browser loses the response (fetch abort),
      # so its own index counter stays at stale_index.
      post_json '/kata/file_create', {
        id:       @id,
        index:    stale_index,
        data:     { file_content: @files },
        filename: 'scratch.txt'
      }
      assert last_response.ok?, last_response.body
      committed_next = saver.kata_events(@id).last['index'] + 1
      assert_operator committed_next, :>, stale_index,
        'the lost inter-test event should have advanced the head'

      # No resync. The next [test] is sent at the STALE index. The saver sees the
      # events the browser missed are all this same laptop's own writes, so it
      # accepts the write as self-lag - no different laptop got in, no mobbing.
      post_run_tests(index: stale_index)
      refute json['out_of_sync'], json
    end
  end

end
