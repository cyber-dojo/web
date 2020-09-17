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
    assert html.match("src='/avatars/image/20'"), 'src: ' + html
    assert html.match("title='wibble'"), 'title: ' + html
    assert html.match("class='avatar-image'"), 'class: ' + html
  end

  #- - - - - - - - - - - - - - - -

  test '647',
  'diff_avatar_image' do
    kata_id = '456eGz'
    avatar_name = 'snake'
    index = 23
    expected = '' +
      '<div' +
      " class='avatar-image'" +
      " data-tip='review #{avatar_name}&#39;s<br/>current code'" +
      " data-id='#{kata_id}'" +
      " data-index='#{index}'>" +
      "<img src='/avatars/image/49'" +
          " alt='#{avatar_name}'/>" +
      '</div>'
    actual = diff_avatar_image(kata_id, 49, index)
    assert_equal expected, actual
  end

end
