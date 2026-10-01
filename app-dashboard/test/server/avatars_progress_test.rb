require_relative 'test_base'
require_relative '../data/cyber-dojo/kata_ids'
require_source 'helpers/gatherer'
require_source 'helpers/avatars_progress'

class AvatarsProgressTest < TestBase

  include AvatarsProgressHelper
  include KataTestData

  attr_reader :params

  test '0D6b46', %w(
  | contract-test v0
  ) do
    @params = { id: V0_GROUP_ID }
    expected = [
      {
        id: V0_KATA_ID,
        avatar_index: 11,
        colour: :green,
        progress: ''
      }
    ]
    actual = avatars_progress
    assert_equal expected, actual
  end

  test '0D6b47', %w(
  | contract-test v1
  ) do
    @params = { id: V1_GROUP_ID }
    expected = [
      {
        id: V1_KATA_ID,
        avatar_index: 26,
        colour: :green,
        progress: 'OK'
      },
      {
        id: '38w9NC',
        avatar_index: 27,
        colour: :red,
        progress: 'FAILED (failures=4)'
      }
    ]
    actual = avatars_progress
    assert_equal expected, actual
  end
  # - - - - - - - - - - - - - - - - -

  test '0D6b48', %w(
  | an avatar that joined a v0/v1 group and never ran a test has only its
  | creation event, and that event carries no colour, so the avatar has no
  | lights at all and is left out of the progress list
  ) do
    saver = LegacyAvatarsSaver.new
    externals.instance_exec { @saver = saver }
    @params = { id: 'anyGroupId' }

    expected = [
      { id: 'rUqcey', avatar_index: 26, colour: :green, progress: '' }
    ]
    assert_equal expected, avatars_progress
  end

  private

  # Stands in for the saver with two avatars shaped as v0/v1 stores them. The
  # first joined and never ran, so its only event is the creation one, which
  # carries just event and time - no colour. (v2 gives that event colour
  # 'create', which is why only legacy data reaches the no-lights case, and
  # PolyFiller never adds a colour that was not stored.) The second ran once.
  class LegacyAvatarsSaver
    CREATED_AT = [2019, 1, 19, 12, 41, 0, 406370].freeze
    RAN_AT = [2019, 1, 19, 12, 42, 0, 0].freeze

    JOINED = {
      '11' => { 'id' => 'k5ZTk0',
                'events' => [{ 'event' => 'created', 'time' => CREATED_AT }] },
      '26' => { 'id' => 'rUqcey',
                'events' => [{ 'event' => 'created', 'time' => CREATED_AT },
                             { 'colour' => 'green', 'index' => 1, 'time' => RAN_AT }] }
    }.freeze

    def group_joined(_id)
      JOINED
    end

    def group_manifest(_id)
      { 'progress_regexs' => [] }
    end

    def katas_events(_ids, _indexes)
      { 'rUqcey' => { '1' => { 'stdout' => { 'content' => 'OK' },
                               'stderr' => { 'content' => '' } } } }
    end
  end
end
