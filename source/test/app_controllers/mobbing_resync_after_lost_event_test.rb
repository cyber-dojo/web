require_relative 'app_controller_test_base'

class MobbingResyncAfterLostEventTest < AppControllerTestBase

  test 'kT9mB2', %w(
  | A solo user on an unshared kata can lose the response to an inter-test
  | file event: the saver commits it and advances the head, but the browser's
  | 2s abort fires so it never applies the returned index. The browser must be
  | able to resync its index from GET /kata/next_index/:id and then run its
  | tests cleanly - it must NOT get a false out-of-sync (mobbing) dialog.
  ) do
    in_kata do |kata|
      # Browser is synced: the only event is the index-0 created event,
      # so the next index to write is 1.
      stale_index = @index
      assert_equal 1, stale_index

      # The browser fires an inter-test file_create. The saver commits it
      # (advancing the head) but the browser loses the response (2s abort),
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

      # Option A resync: rather than staying stale, the browser re-reads its
      # authoritative next index from the server.
      get '/kata/next_index/' + @id
      assert last_response.ok?, last_response.body
      assert_equal committed_next, json['next_index']

      # With the resynced index the next run-tests saves cleanly: no mobbing.
      post_run_tests(index: json['next_index'])
      refute json['out_of_sync'], json
    end
  end

end
