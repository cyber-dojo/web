require_relative 'app_helpers_test_base'

class DiffAvatarImageTest < AppHelpersTestBase

  def self.hex_prefix
    'E30'
  end

  include DiffAvatarImageHelper

  test '647',
  'diff_avatar_image' do
    kata_id = '456eGz'
    avatar_index = 49
    last_light_index = 23
    expected = '' +
      '<div' +
      " class='avatar-image'" +
      " data-id='#{kata_id}'" +
      " data-avatar-index='#{avatar_index}'" +
      " data-index='#{last_light_index}'>" +
      "<img src='/images/avatars/49.jpg'/>" +
      '</div>'
    actual = diff_avatar_image(kata_id, avatar_index, last_light_index)
    assert_equal expected, actual
  end

end
