
module AvatarImageHelper # mix-in

  module_function

  def avatar_image(name, size, title = name)
    name = name.downcase
    "<img src='/images/avatars/#{name.downcase}.jpg'" +
      " title='#{title.downcase}'" +
      " width='#{size}'" +
      " height='#{size}'" +
      " class='avatar-image'/>"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def diff_avatar_image(kata_id, avatar_index)
    apostrophe = '&#39;'
    avatar_name = Avatars.names[avatar_index]
    "<div class='avatar-image'" +
        " data-tip='review #{avatar_name}#{apostrophe}s<br/>current code'" +
        " data-id='#{kata_id}'>" +
        "<img src='/avatar/image/#{avatar_index}'" +
            " alt='#{avatar_name}'/>" +
     '</div>'
  end

end
