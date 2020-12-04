require_relative 'app_models_test_base'
require_relative '../../app/services/saver_service'

class KataTest < AppModelsTestBase

  def self.hex_prefix
    'Fb9'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B7F', %w(
  using existing kata.methods (except for exists?)
  when params does not specify a version number
  forces schema.version determination via the manifest
  ) do
    set_saver_class('SaverService')
    katas = Katas.new(self, {})
    kata = katas['5rTJv5']
    assert_equal 'Ruby, MiniTest', kata.manifest['display_name']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?

  test '760', %w(
  exists? is true,
  for a well-formed kata-id that exists,
  when saver is online
  ) do
    in_new_kata do |kata|
      assert kata.exists?
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '761', %w(
  exists? is false,
  for a well-formed kata-id that does not exist,
  when saver is online
  ) do
    refute katas['123AbZ'].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '762', %w(
  exists? is false,
  for a malformed kata-id,
  when saver is online
  ) do
    refute katas[42].exists?, 'Integer'
    refute katas[nil].exists?, 'nil'
    refute katas[[]].exists?, '[]'
    refute katas[{}].exists?, '{}'
    refute katas[true].exists?, 'true'
    refute katas[''].exists?, 'length == 0'
    refute katas['12345'].exists?, 'length == 5'
    refute katas['12345i'].exists?, '!id?()'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '862', %w(
  an individual kata is created from a well-formed manifest,
  is empty,
  and is not a member of a group
  ) do
    in_new_kata do |kata|
      assert kata.exists?
      assert_equal 1, kata.events.size
      assert_nil kata.manifest['group_id']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '864', %w(
  after run_tests()/ran_tests(),
  there is a new traffic-light event,
  which is now the most recent event
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
  after revert,
  there is a new traffic-light event,
  which is now the most recent event
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
  kata.event(-1) returns the most recent event
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

  test '824', %w(
  given a saver outage during a session
  when kata.event(-1) is called
  then v0 raises
  but v1 handles it
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
        assert_raises { kata.event(-1) }
      else
        assert_equal 'x1x2x3', kata.event(-1)['stdout']['content']
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '825', %w(
  given two laptops as the same avatar
  when one is behind (has not synced by hitting refresh in their browser)
  and they hit the [test] button
  a ModelService::Error is raised
  and a new event is not created in the saver
  ) do
    set_saver_class('SaverService')
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
      assert_raises(ModelService::Error) {
        kata.event(4) # /4/event.json not created
      }

      # 2nd avatar - no refresh, so index not advanced to 2
      error = assert_raises(ModelService::Error) {
        kata_ran_tests(kata.id, 1, files, stdout, stderr, status, ran_summary('green'))
      }

      events = kata.events
      assert_equal 4, events.size, :event_not_appended_to_events_json
      assert_raises(ModelService::Error) {
        kata.event(4) # /4.event.json not created
      }

      # Depends on version
      # v1 had index, v0 does not...

      #assert_equal 0, events[0]['index'] # creation
      #assert_equal 1, events[1]['index']
      #assert_equal 2, events[2]['index']
      #assert_equal 3, events[3]['index']

      assert_equal 'red', events[1]['colour']
      assert_equal 'amber', events[2]['colour']
      assert_equal 'green', events[3]['colour']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '826', %w(
  the default colour-theme is light as its better for projection
  ) do
    in_new_kata do |kata|
      assert_equal 'light', kata.theme
    end
  end

  v_tests [0,1], '926', %w(
  setting the colour-theme is persistent
  ) do
    in_new_kata do |kata|
      kata.theme = 'light'
      assert_equal 'light', kata.theme
      kata.theme = 'dark'
      assert_equal 'dark', kata.theme
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '827', %w(
  the default for colour-syntax is on
  ) do
    in_new_kata do |kata|
      assert_equal 'on', kata.colour
    end
  end

  v_tests [0,1], '927', %w(
  setting the colour-syntax is persistent
  ) do
    in_new_kata do |kata|
      kata.colour = 'off'
      assert_equal 'off', kata.colour
      kata.colour = 'on'
      assert_equal 'on', kata.colour
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  v_tests [0,1], '828', %w(
  the default for prediction is off
  ) do
    in_new_kata do |kata|
      assert_equal 'off', kata.predict
    end
  end

  v_tests [0,1], '928', %w(
  setting the prediction is persistent
  ) do
    in_new_kata do |kata|
      kata.predict = 'on'
      assert_equal 'on', kata.predict
      kata.predict = 'off'
      assert_equal 'off', kata.predict
    end
  end

end
