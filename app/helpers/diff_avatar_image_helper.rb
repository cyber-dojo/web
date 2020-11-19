# frozen_string_literal: true

module DiffAvatarImageHelper # mix-in

  module_function

  def diff_avatar_image(kata_id, avatar_index)
    apostrophe = '&#39;'
    "<div class='avatar-image'" +
        " data-id='#{kata_id}'" +
        " data-avatar-index='#{avatar_index}'>" +
        "<img src='/images/avatars/#{avatar_index}.jpg'/>" +
     '</div>'
  end

end
