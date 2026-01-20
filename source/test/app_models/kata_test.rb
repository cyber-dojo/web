require_relative 'app_models_test_base'

class KataTest < AppModelsTestBase

  def self.hex_prefix
    'Fb9'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '862', %w(
  | an individual kata is created from a well-formed manifest,
  | and is not a member of a group
  ) do
    in_new_kata do |kata|
      assert_equal 1, kata.events.size
      assert_nil kata.manifest['group_id']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '864', %w(
  | after run_tests()/ran_tests(),
  | there is a new traffic-light event,
  | which is now the most recent event
  ) do
    in_new_kata do |kata|
      files = kata.event(-1)['files']
      stdout = content('dfg')
      stderr = content('uystd')
      status = 3
      kata_ran_tests(kata.id, 1, files, stdout, stderr, status, ran_summary('red'))

      assert_equal 2, kata.events.size
      light = kata.event(-1)
      assert_equal stdout, light['stdout']
      assert_equal stderr, light['stderr']
      assert_equal status, light['status']
      assert_equal files, light['files']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '860', %w(
  | after revert,
  | there is a new traffic-light event,
  | which is now the most recent event
  ) do
    in_new_kata do |kata|
      files = kata.event(-1)['files']
      stdout_1 = content("Expected: 42\nActual: 54")
      stderr_1 = content('assert failed')
      status_1 = 4
      kata_ran_tests(kata.id, 1, files, stdout_1, stdout_1, stderr_1, ran_summary('red'))

      filename = 'hiker.sh'
      hiker_rb = files[filename]['content']
      files[filename] = content(hiker_rb.sub('6 * 9','6 * 7'))
      stdout_2 = content('All tests passed')
      stderr_2 = content('')
      status_2 = 0
      kata_ran_tests(kata.id, 2, files, stdout_2, stderr_2, status_2, ran_summary('green'))

      kata_revert(kata.id, 3, kata.event(1)['files'], stdout_1, stderr_1, status_1, {
          'time' => time.now,
        'colour' => 'red',
        'revert' => [ kata.id, 1 ]
      });

      assert_equal 4, kata.events.size
      light = kata.event(-1)
      assert_equal [ kata.id, 1 ], light['revert']
      assert_equal 'red', light['colour']

      assert_equal stdout_1, light['stdout']
      assert_equal stderr_1, light['stderr']
      assert_equal status_1, light['status']

      assert_equal kata.event(1)['files'], light['files']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '866', %w(
  | kata.event(-1) returns the most recent event
  ) do
    in_new_kata do |kata|
      assert_equal kata.event(0), kata.event(-1)
      files = kata.event(-1)['files']
      stdout = content('xxxx')
      stderr = content('')
      status = 0
      kata_ran_tests(kata.id, 1, files, stdout, stderr, status, ran_summary('green'))

      assert_equal 'xxxx', kata.event(-1)['stdout']['content']
      assert_equal kata.event(1), kata.event(-1)
      stdout = content('')
      stderr = content('syntax-error')
      status = 1
      kata_ran_tests(kata.id, 2, files, stdout, stderr, status, ran_summary('green'))

      assert_equal 'syntax-error', kata.event(-1)['stderr']['content']
      assert_equal kata.event(2), kata.event(-1)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1,2], '824', %w(
  | given a saver outage during a session
  | when kata.event(-1) is called
  | then v0 raises
  | but v1 v2 handles it
  ) do
    in_new_kata do |kata|
      files = kata.event(-1)['files']
      stdout = content('aaaa')
      stderr = content('bbbb')
      status = 1
      kata_ran_tests(kata.id, 1, files, stdout, stderr, status, ran_summary('red'))

      # saver-outage for index=2,3,4,5
      stdout['content'] = 'x1x2x3'
      kata_ran_tests(kata.id, 6, files, stdout, stderr, status, ran_summary('red'))

      if v_test?(0)
        captured_stdout {
          assert_raises { kata.event(-1) }
        }
      else
        assert_equal 'x1x2x3', kata.event(-1)['stdout']['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1,2], '825', %w(
  | given two laptops as the same avatar
  | when one is behind (has not synced by hitting refresh in their browser)
  | and they hit the [test] button
  | a SaverService::Error is raised
  | and a new event is not created in the saver
  ) do
    in_new_kata do |kata|
      files = kata.event(-1)['files']
      stdout = content('aaaa')
      stderr = content('bbbb')
      status = 1
      # 1st avatar
      kata_ran_tests(kata.id, 1, files, stdout, stderr, status, ran_summary('red'))
      kata_ran_tests(kata.id, 2, files, stdout, stderr, status, ran_summary('amber'))
      kata_ran_tests(kata.id, 3, files, stdout, stderr, status, ran_summary('green'))

      events = kata.events
      assert_equal 4, events.size, :event_not_appended_to_events_json
      captured_stdout {
        assert_raises(SaverService::Error) {
          kata.event(4) # /4/event.json not created
        }
      }

      # 2nd avatar - no refresh, so index not advanced to 2
      captured_stdout {
        assert_raises(SaverService::Error) {
          kata_ran_tests(kata.id, 1, files, stdout, stderr, status, ran_summary('green'))
        }
      }

      events = kata.events
      assert_equal 4, events.size, :event_not_appended_to_events_json

      captured_stdout {
        assert_raises(SaverService::Error) {
          kata.event(4) # /4.event.json not created
        }
      }

      assert_equal 0, events[0]['index'] # creation
      assert_equal 1, events[1]['index']
      assert_equal 2, events[2]['index']
      assert_equal 3, events[3]['index']

      assert_equal 'red', events[1]['colour']
      assert_equal 'amber', events[2]['colour']
      assert_equal 'green', events[3]['colour']
    end
  end

  private

  def captured_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('', 'w')
      yield
      captured = $stdout.string
    ensure
      $stdout = old_stdout
    end
    captured
  end

end
