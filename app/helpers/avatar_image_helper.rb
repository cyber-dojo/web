# frozen_string_literal: true

module AvatarImageHelper # mix-in

  module_function

  def avatar_image(name, size, title = name)
    avatar_index = Avatars.index(name.downcase)
    "<img src='/images/avatars/#{avatar_index}.jpg'" +
      " title='#{title.downcase}'" +
      " width='#{size}'" +
      " height='#{size}'" +
      " class='avatar-image'/>"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def diff_avatar_image(kata_id, avatar_index, last_light_index)
    apostrophe = '&#39;'
    "<div class='avatar-image'" +
        " data-id='#{kata_id}'" +
        " data-avatar-index='#{avatar_index}'" +
        " data-index='#{last_light_index}'>" +
        "<img src='/images/avatars/#{avatar_index}.jpg'/>" +
     '</div>'
  end

end
