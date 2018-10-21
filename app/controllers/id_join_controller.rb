
class IdJoinController < ApplicationController

  # Only for a group practice-session
  def drop_down
    gid = porter.port(id)
    group = groups[gid]
    json = { exists:group.exists? }
    if json[:exists]
      avatar = group.join
      json[:full] = avatar.nil?
      if json[:full]
        json[:fullHtml] = full_html
      else
        json[:id] = gid
        json[:avatarName] = avatar.name
        json[:avatarStartHtml] = start_html(avatar.name)
      end
    end
    render json:json
  end

  private

  def start_html(avatar_name)
    @avatar_name = avatar_name
    bind('/app/views/id_join/start.html.erb')
  end

  def full_html
    @all_avatar_names = Avatars.names
    bind('/app/views/id_join/full.html.erb')
  end

end
