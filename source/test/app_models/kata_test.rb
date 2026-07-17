require_relative 'app_models_test_base'

class KataTest < AppModelsTestBase

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Fb9862', %w(
  | an individual kata is created from a well-formed manifest,
  | and is not a member of a group
  ) do
    in_new_kata do |kata|
      assert_equal 1, kata.events.size
      assert_nil kata.manifest['group_id']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Fb9864', %w(
  | after run_tests()/ran_tests(),
  | there is a new traffic-light event,
  | which is now the most recent event
  ) do
    in_new_kata do |kata|
      files = kata.event(-1)['files']
      stdout = content('dfg')
      stderr = content('uystd')
      status = 3
      kata_ran_tests(kata.id, files, stdout, stderr, status, ran_summary('red'), laptop_id)

      assert_equal 2, kata.events.size
      light = kata.event(-1)
      assert_equal stdout, light['stdout']
      assert_equal stderr, light['stderr']
      assert_equal status.to_s, light['status']
      assert_equal files, light['files']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Fb9860', %w(
  | after revert,
  | there is a new traffic-light event,
  | which is now the most recent event
  ) do
    in_new_kata do |kata|
      files = kata.event(-1)['files']
      stdout_1 = content("Expected: 42\nActual: 54")
      stderr_1 = content('assert failed')
      status_1 = 4
      result = kata_ran_tests(kata.id, files, stdout_1, stderr_1, status_1, ran_summary('red'), laptop_id)

      filename = 'hiker.sh'
      hiker_rb = files[filename]['content']
      files[filename] = content(hiker_rb.sub('6 * 9','6 * 7'))
      stdout_2 = content('All tests passed')
      stderr_2 = content('')
      status_2 = 0
      result = kata_ran_tests(kata.id, files, stdout_2, stderr_2, status_2, ran_summary('green'), laptop_id)

      kata_revert(kata.id, kata.event(1)['files'], stdout_1, stderr_1, status_1, {
          'time' => time.now,
        'colour' => 'red',
        'revert' => [ kata.id, 1 ]
      }, laptop_id);

      light = kata.event(-1)
      assert_equal [ kata.id, 1 ], light['revert']
      assert_equal 'red', light['colour']

      assert_equal stdout_1, light['stdout']
      assert_equal stderr_1, light['stderr']
      assert_equal status_1.to_s, light['status']

      assert_equal kata.event(1)['files'], light['files']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Fb9866', %w(
  | kata.event(-1) returns the most recent event
  ) do
    in_new_kata do |kata|
      assert_equal kata.event(0), kata.event(-1)
      files = kata.event(-1)['files']
      stdout = content('xxxx')
      stderr = content('')
      status = 0
      kata_ran_tests(kata.id, files, stdout, stderr, status, ran_summary('green'), laptop_id)

      assert_equal 'xxxx', kata.event(-1)['stdout']['content']
      assert_equal kata.event(1), kata.event(-1)
      stdout = content('')
      stderr = content('syntax-error')
      status = 1
      kata_ran_tests(kata.id, files, stdout, stderr, status, ran_summary('green'), laptop_id)

      assert_equal 'syntax-error', kata.event(-1)['stderr']['content']
      assert_equal kata.event(2), kata.event(-1)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Fb9825', %w(
  | given two laptops as the same avatar (two different laptop_ids)
  | when one is behind (has not synced by hitting refresh in their browser)
  | and they hit the [test] button
  | the saver accepts the write, placing it at head+1 (a behind write is no longer
  | rejected - detection is read-side now), so a new event IS created.
  ) do
    laptop_a = 'a1' * 32
    laptop_b = 'b2' * 32
    in_new_kata do |kata|
      files = kata.event(-1)['files']
      stdout = content('aaaa')
      stderr = content('bbbb')
      status = 1
      # 1st laptop drives the kata to head 3
      kata_ran_tests(kata.id, files, stdout, stderr, status, ran_summary('red'),   laptop_a)
      kata_ran_tests(kata.id, files, stdout, stderr, status, ran_summary('amber'), laptop_a)
      kata_ran_tests(kata.id, files, stdout, stderr, status, ran_summary('green'), laptop_a)

      events = kata.events
      assert_equal 4, events.size, :event_not_appended_to_events_json

      # 2nd laptop has NOT refreshed, so its write lands behind the head over events
      # a DIFFERENT laptop wrote. The saver no longer rejects that: it places the
      # write at head+1 and appends it. The stale tab is caught read-side (the
      # browser poll), not here.
      kata_ran_tests(kata.id, files, stdout, stderr, status, ran_summary('green'), laptop_b)

      events = kata.events
      assert_equal 5, events.size, :event_appended_at_head_plus_1

      assert_equal 0, events[0]['index'] # creation
      assert_equal 1, events[1]['index']
      assert_equal 2, events[2]['index']
      assert_equal 3, events[3]['index']
      assert_equal 4, events[4]['index']

      assert_equal 'red',   events[1]['colour']
      assert_equal 'amber', events[2]['colour']
      assert_equal 'green', events[3]['colour']
      assert_equal 'green', events[4]['colour']
    end
  end

  private

  def captured_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new(+'', 'w')
      yield
      captured = $stdout.string
    ensure
      $stdout = old_stdout
    end
    captured
  end

end
