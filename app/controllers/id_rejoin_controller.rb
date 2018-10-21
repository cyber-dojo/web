
class IdRejoinController < ApplicationController

  def drop_down
    # TODO: individual-rejoin
    @id = porter.port(id)
    group = groups[@id]
    json = { exists:group.exists? }
    if json[:exists]
      avatars = group.avatars
      json[:empty] = (avatars.size == 0)
      json[:avatarPickerHtml] = avatar_picker_html(avatars.keys)
    end
    render json:json
  end

  private

  def avatar_picker_html(started_avatar_names)
    @all_avatar_names = Avatars.names
    @started_avatar_names = started_avatar_names
    bind('/app/views/id_rejoin/avatar_picker.html.erb')
  end

end
