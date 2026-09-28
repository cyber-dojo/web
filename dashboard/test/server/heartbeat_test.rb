require_relative 'test_base'
require_relative 'saver_data_builder'
require 'json'

class HeartbeatTest < TestBase
  include SaverDataBuilder

  # - - - - - - - - - - - - - - - - -

  test 'h4b7t1', %w(
  | GET /heartbeat/<group-id> returns, for each avatar that has activity, its
  | kata_id and its traffic-lights bucketed into minute columns, plus one
  | time_tick per column. An avatar that has only joined, with no test run,
  | has no activity so it is absent.
  ) do
    group_id = create_group('Bash, bats')
    ran_kata_id = join_avatar(group_id)
    give_traffic_light(ran_kata_id)
    join_avatar(group_id) # joined only - no run, so no activity, so absent

    response = get_heartbeat(group_id)
    assert_equal %w[avatars time_ticks], response.keys.sort, response

    avatars = response['avatars']
    assert_equal 1, avatars.size, avatars
    avatar = avatars.values[0]
    assert_equal %w[kata_id lights], avatar.keys.sort, avatar
    assert_equal ran_kata_id, avatar['kata_id'], avatar

    lights = avatar['lights']
    assert_equal ['0'], lights.keys, lights
    column = lights['0']
    assert_equal 1, column.size, column

    light = column[0]
    assert_equal %w[colour index major_index minor_index previous_index time],
                 light.keys.sort, light
    assert_equal 'green', light['colour'], light
    assert_equal 1, light['index'], light
    assert_equal 0, light['previous_index'], light

    assert_equal ['0'], response['time_ticks'].keys, response['time_ticks']
  end

  # - - - - - - - - - - - - - - - - -

  test 'h4b7t2', %w(
  | GET /heartbeat?minute_columns=false widens one column from a minute to
  | effectively forever, so a lone light still sits in column 0 but that
  | column's time_tick spans 365000 days instead of one minute
  ) do
    group_id = create_group('Bash, bats')
    give_traffic_light(join_avatar(group_id))

    assert_equal({ '0' => [0, 0, 1] },
                 get_heartbeat(group_id)['time_ticks'])
    assert_equal({ '0' => [365_000, 0, 0] },
                 get_heartbeat(group_id, 'minute_columns=false')['time_ticks'])
  end

  # - - - - - - - - - - - - - - - - -

  test 'h4b7t3', %w(
  | GET /heartbeat?detailed=true also shows inter-test events, those with a
  | non-zero index that are not traffic-lights, where the default view shows
  | traffic-lights alone
  ) do
    group_id = create_group('Bash, bats')
    kata_id = join_avatar(group_id)
    give_traffic_light(kata_id)
    edit_a_file(kata_id)

    assert_equal 1, lights_of(get_heartbeat(group_id)).size, 'plain'
    assert_equal 2, lights_of(get_heartbeat(group_id, 'detailed=true')).size, 'detailed'
  end

  # - - - - - - - - - - - - - - - - -

  test 'h4b7t4', %w(
  | a traffic-light's json carries predicted, revert and checkout only when its
  | own event has them, so a predicted run, a revert and a checkout each add
  | exactly one field to the base light
  ) do
    group_id = create_group('Bash, bats')
    kata_id = join_avatar(group_id)
    give_predicted_light(kata_id)
    give_reverted_light(kata_id)
    give_checked_out_light(kata_id)

    lights = lights_of(get_heartbeat(group_id))
    assert_equal 3, lights.size, lights
    base = %w[colour index major_index minor_index previous_index time]
    assert_equal [['predicted'], ['revert'], ['checkout']],
                 lights.map { |light| light.keys.sort - base }, lights
  end

  # - - - - - - - - - - - - - - - - -

  CREATED = [2026, 7, 22, 9, 0, 0, 0].freeze
  FIRST_LIGHT_TIME = [2026, 7, 22, 9, 0, 30, 0].freeze
  LATER_LIGHT_TIME = [2026, 7, 22, 9, 10, 30, 0].freeze
  NOW = [2026, 7, 22, 9, 11, 0, 0].freeze

  test 'h4b7t5', %w(
  | when two lights are further apart than the uncollapsed maximum, the columns
  | between them collapse into a single column carrying the count of columns it
  | stands for, and that column's time_tick is that same collapsed count rather
  | than a days/hours/minutes triple
  ) do
    events = [
      { 'index' => 0, 'colour' => 'create', 'time' => CREATED },
      { 'index' => 1, 'colour' => 'green', 'major_index' => 1, 'minor_index' => 0,
        'time' => FIRST_LIGHT_TIME },
      { 'index' => 2, 'colour' => 'red', 'major_index' => 2, 'minor_index' => 0,
        'time' => LATER_LIGHT_TIME }
    ]
    joined = { '11' => { 'id' => 'kAtA01', 'events' => events } }
    saver = SaverStub.new(joined, { 'created' => CREATED })
    time = TimeStub.new(NOW)
    externals.instance_exec { @saver = saver; @time = time }

    expected = {
      'time_ticks' => {
        '0' => [0, 0, 1],
        '1' => { 'collapsed' => 9 },
        '10' => [0, 0, 11]
      },
      'avatars' => {
        '11' => {
          'kata_id' => 'kAtA01',
          'lights' => {
            '0' => [{ 'previous_index' => 0, 'index' => 1, 'major_index' => 1,
                      'minor_index' => 0, 'colour' => 'green',
                      'time' => FIRST_LIGHT_TIME }],
            '1' => { 'collapsed' => 9 },
            '10' => [{ 'previous_index' => 1, 'index' => 2, 'major_index' => 2,
                       'minor_index' => 0, 'colour' => 'red',
                       'time' => LATER_LIGHT_TIME }]
          }
        }
      }
    }
    assert_equal expected, get_heartbeat('anyGroupId')
  end

  private

  # GETs /heartbeat/<id> as json, asserts 200, and returns the parsed body.
  def get_heartbeat(id, query = '')
    get mounted_path("heartbeat/#{id}?#{query}"), {}, { 'HTTP_ACCEPT' => 'application/json' }
    assert status?(200), "status=#{status}"
    JSON.parse(last_response.body)
  end

  # Every event the response shows, across all avatars and columns, index order.
  def lights_of(response)
    response['avatars'].values.flat_map do |avatar|
      avatar['lights'].values.select { |column| column.is_a?(Array) }.flatten
    end.sort_by { |light| light['index'] }
  end
  # Stands in for the saver so a test owns every light's time, which the real
  # saver stamps from its own clock. gather needs only these two calls.
  class SaverStub
    def initialize(joined, manifest)
      @joined = joined
      @manifest = manifest
    end

    def group_joined(_id)
      @joined
    end

    def group_manifest(_id)
      @manifest
    end
  end

  # Stands in for ExternalTime so "now" is fixed relative to the light times.
  class TimeStub
    def initialize(now)
      @now = now
    end

    attr_reader :now
  end
end
