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
    assert html.match("src='/images/avatars/#{name}.jpg'"), 'src: ' + html
    assert html.match("title='wibble'"), 'title: ' + html
    assert html.match("class='avatar-image'"), 'class: ' + html
  end

  #- - - - - - - - - - - - - - - -

  test '647',
  'diff_avatar_image' do
    kata_id = '456eGz'
    avatar_name = 'snake'
    expected = '' +
      '<div' +
      " class='avatar-image'" +
      " data-tip='review #{avatar_name}&#39;s<br/>current code'" +
      " data-id='#{kata_id}'>" +
      "<img src='/images/avatars/#{avatar_name}.jpg'" +
          " alt='#{avatar_name}'/>" +
      '</div>'
    index = Avatars.names.index(avatar_name)
    actual = diff_avatar_image(kata_id, index)
    assert_equal expected, actual
  end

end
