require_relative 'app_helpers_test_base'

class AvatarImageTest < AppHelpersTestBase

  def self.hex_prefix
    'E30'
  end

  include AvatarImageHelper

  test 'BAA',
  'avatar_image html' do
    html = avatar_image(name = 'hippo', size = 42, title = 'wibble')
    assert html.start_with?('<img '), '<img : ' + html
    assert html.match("height='#{size}'"), 'height: ' + html
    assert html.match("width='#{size}'"), 'width: ' + html
    assert html.match("src='/images/avatars/20.jpg'"), 'src: ' + html
    assert html.match("title='wibble'"), 'title: ' + html
    assert html.match("class='avatar-image'"), 'class: ' + html
  end

  #- - - - - - - - - - - - - - - -

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
