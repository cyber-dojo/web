require_relative 'app_helpers_test_base'

class PrevNextAvatarIdsTest < AppHelpersTestBase

  def self.hex_prefix
    'f75'
  end

  include PrevNextAvatarIdsHelper

  test '842', %w(
  |when arg1=id is only entry in katas_indexes
  |then prev_avatar_id is empty string
  |and  next_avatar_id is empty string
  ) do
    id = 'w34rd5'
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, [
      [ id, 2 ],
    ])
    assert_equal '', prev_avatar_id
    assert_equal '', next_avatar_id
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '843', %w(
  |when only one avatar is before arg1=id
  |then prev_avatar_id is the before avatar's id
  |and  next_avatar_id is the empty string
  ) do
    prev_id = 'TZ6f29'
    id = 'w34rd5'
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, [
      [ prev_id,  2 ],
      [      id, 12 ],
    ])
    assert_equal prev_id, prev_avatar_id
    assert_equal '', next_avatar_id
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '844', %w(
  |when only one avatar is after arg1=id
  |then prev_avatar_id is the empty string
  |and  next_avatar_id is the after avatar's id
  ) do
    id = 'w34rd5'
    next_id = 'TZ6f29'
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, [
      [      id,  2 ],
      [ next_id, 27 ],
    ])
    assert_equal '', prev_avatar_id
    assert_equal next_id, next_avatar_id
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '845', %w(
  |when avatars are before and after arg1=id
  |then prev_avatar_id is the before avatar's id
  |and  next_avatar_id is the after avatar's id
  ) do
    prev_id = 'SyG9sT'
    id = 'w34rd5'
    next_id = 'TZ6f29'
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, [
      [ prev_id,  2 ],
      [      id, 13 ],
      [ next_id, 27 ],
    ])
    assert_equal prev_id, prev_avatar_id
    assert_equal next_id, next_avatar_id
  end

end
