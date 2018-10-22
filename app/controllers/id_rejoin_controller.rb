
class IdRejoinController < ApplicationController

  def drop_down
    # TODO: individual-rejoin
    group = groups[porter.port(id)]
    json = { exists:group.exists? }
    if json[:exists]
      avatars = group.avatars
      json[:empty] = (avatars.size == 0)
      json[:avatarPickerHtml] = avatar_picker_html(avatars)
    end
    render json:json
  end

  private

  def avatar_picker_html(started_avatars)
    @all_avatar_names = Avatars.names
    @started_avatars = started_avatars
    bind('/app/views/id_rejoin/avatar_picker.html.erb')
  end

end
