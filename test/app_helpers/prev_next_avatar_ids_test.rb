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
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, ge={
      id => { "index" => 2, "events" => [0,1,2] }
    })
    assert_equal '', prev_avatar_id
    assert_equal '', next_avatar_id
    # avatars that have not yet pressed [test] are ignored
    ge['112233'] = { "index" => 0, "events" => [0] }
    ge['332255'] = { "index" => 4, "events" => [0] }
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, ge)
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
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, ge={
      prev_id => { "index" =>  2, "events" => [0,1,2,3    ] },
           id => { "index" => 12, "events" => [0,1,2,3,4,5] },
    })
    assert_equal prev_id, prev_avatar_id
    assert_equal '', next_avatar_id
    # avatars that have not yet pressed [test] are ignored
    ge['112233'] = { "index" =>  0, "events" => [0] }
    ge['332255'] = { "index" =>  4, "events" => [0] }
    ge['657543'] = { "index" => 42, "events" => [0] }
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, ge)
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
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, ge={
           id => { "index" =>  2, "events" => [0,1,2,3,4] },
      next_id => { "index" => 27, "events" => [0,1      ] },
    })
    assert_equal '', prev_avatar_id
    assert_equal next_id, next_avatar_id
    # avatars that have not yet pressed [test] are ignored
    ge['112233'] = { "index" =>  0, "events" => [0] }
    ge['dSef54'] = { "index" =>  1, "events" => [0] }
    ge['332255'] = { "index" =>  4, "events" => [0] }
    ge['657543'] = { "index" => 42, "events" => [0] }
    ge['9QwS39'] = { "index" => 61, "events" => [0] }
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, ge)
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
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, ge={
      prev_id => { "index" =>  9, "events" => [0,1,2,3,4  ] },
           id => { "index" => 13, "events" => [0,1        ] },
      next_id => { "index" => 27, "events" => [0,1,2,3,4,5] },
    })
    assert_equal prev_id, prev_avatar_id
    assert_equal next_id, next_avatar_id
    # avatars that have not yet pressed [test] are ignored
    ge['112233'] = { "index" =>  0, "events" => [0] }
    ge['dSef54'] = { "index" =>  3, "events" => [0] }
    ge['332255'] = { "index" => 14, "events" => [0] }
    ge['33xx55'] = { "index" => 15, "events" => [0] }
    ge['657543'] = { "index" => 42, "events" => [0] }
    ge['9QwS39'] = { "index" => 61, "events" => [0] }
    prev_avatar_id,next_avatar_id = prev_next_avatar_ids(id, ge)
    assert_equal prev_id, prev_avatar_id
    assert_equal next_id, next_avatar_id
  end

end
