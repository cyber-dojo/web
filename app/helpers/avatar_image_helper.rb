# frozen_string_literal: true

module AvatarImageHelper # mix-in

  module_function

  def avatar_image(name, size, title = name)
    avatar_index = Avatars.index(name.downcase)
    "<img src='/avatars/image/#{avatar_index}'" +
      " title='#{title.downcase}'" +
      " width='#{size}'" +
      " height='#{size}'" +
      " class='avatar-image'/>"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def diff_avatar_image(kata_id, avatar_index, index)
    apostrophe = '&#39;'
    avatar_name = Avatars.names[avatar_index]
    "<div class='avatar-image'" +
        " data-tip='review #{avatar_name}#{apostrophe}s<br/>current code'" +
        " data-id='#{kata_id}'" +
        " data-index='#{index}'>" +
        "<img src='/avatars/image/#{avatar_index}'" +
            " alt='#{avatar_name}'/>" +
     '</div>'
  end

end
