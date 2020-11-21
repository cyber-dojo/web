require_relative 'app_helpers_test_base'

class PrevNextAvatarIdsTest < AppHelpersTestBase

  def self.hex_prefix
    'f75'
  end

  include PrevNextAvatarIdsHelper

  test '841', %w(
  |when arg1-id is for kata not in a group, arg-joined === {}
  |then prev_id is empty string
  |and  next_id is empty string
  |and  index is nil
  ) do
    id = 'RNCzUr'
    expected = [ '', nil, '' ]
    actual = prev_next_avatar_ids(id, joined={})
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '842', %w(
  |when arg1-id is only entry in katas_indexes
  |then prev_id is empty string
  |and  next_id is empty string
  |and index is index of kata in group
  ) do
    id = 'w34rd5'
    expected = [ '', 2, '' ]
    actual = prev_next_avatar_ids(id, joined={
      '2' => { 'id' => id, 'events' => [0,1,2] }
    })
    assert_equal expected, actual

    # avatars that have not yet pressed [test] are ignored
    joined['0'] = { 'id' => '112233', 'events' => [0] }
    joined['4'] = { 'id' => '332255', 'events' => [0] }
    actual = prev_next_avatar_ids(id, joined)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '843', %w(
  |when only one avatar is before arg1-id
  |then prev_id is the before avatar's id
  |and  next_id is the empty string
  |and index is index of kata in group
  ) do
    id = 'w34rd5'
    prev_id = 'TZ6f29'
    expected = [ prev_id, 12, '' ]
    actual = prev_next_avatar_ids(id, joined={
       '2' => { 'id' => prev_id, 'events' => [0,1,2,3    ] },
      '12' => { 'id' => id     , 'events' => [0,1,2,3,4,5] },
    })
    assert_equal expected, actual

    # avatars that have not yet pressed [test] are ignored
    joined[ '0'] = { 'id' => '112233', 'events' => [0] }
    joined[ '4'] = { 'id' => '332255', 'events' => [0] }
    joined['42'] = { 'id' => '657543', 'events' => [0] }
    actual = prev_next_avatar_ids(id, joined)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '844', %w(
  |when only one avatar is after arg1=id
  |then prev_id is the empty string
  |and  next_id is the after avatar's id
  |and index is index of kata in group
  ) do
    id = 'w34rd5'
    next_id = 'TZ6f29'
    expected = [ '', 2, next_id ]
    actual = prev_next_avatar_ids(id, joined={
       '2' => { 'id' => id     , 'events' => [0,1,2,3,4] },
      '27' => { 'id' => next_id, 'events' => [0,1      ] },
    })
    assert_equal expected, actual

    # avatars that have not yet pressed [test] are ignored
    joined[ '0'] = { 'id' => '112233', 'events' => [0] }
    joined[ '1'] = { 'id' => 'dSef54', 'events' => [0] }
    joined[ '4'] = { 'id' => '332255', 'events' => [0] }
    joined['42'] = { 'id' => '657543', 'events' => [0] }
    joined['61'] = { 'id' => '9QwS39', 'events' => [0] }
    actual = prev_next_avatar_ids(id, joined)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '845', %w(
  |when avatars are before and after arg1=id
  |then prev_id is the before avatar's id
  |and  next_id is the after avatar's id
  |and index is index of kata in group
  ) do
    prev_id = 'SyG9sT'
    id = 'w34rd5'
    next_id = 'TZ6f29'
    expected = [ prev_id, 13, next_id ]
    actual = prev_next_avatar_ids(id, joined={
       '9' => { 'id' => prev_id, 'events' => [0,1,2,3,4  ] },
      '13' => { 'id' =>      id, 'events' => [0,1        ] },
      '27' => { 'id' => next_id, 'events' => [0,1,2,3,4,5] },
    })
    assert_equal expected, actual

    # avatars that have not yet pressed [test] are ignored
    joined[ '0'] = { 'id' => '112233', 'events' => [0] }
    joined[ '3'] = { 'id' => 'dSef54', 'events' => [0] }
    joined['14'] = { 'id' => '332255', 'events' => [0] }
    joined['15'] = { 'id' => '33xx55', 'events' => [0] }
    joined['42'] = { 'id' => '657543', 'events' => [0] }
    joined['61'] = { 'id' => '9QwS39', 'events' => [0] }
    actual = prev_next_avatar_ids(id, joined)
    assert_equal expected, actual
  end

end
