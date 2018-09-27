
class IdJoinController < ApplicationController

  # Only for a group practice-session
  def drop_down
    @id = params['id'] = grouper.id_completed(id)
    json = { exists: @id != '' }
    if json[:exists]
      index,sid = grouper.join(@id)
      json[:full] = index.nil?
      if json[:full]
        json[:fullHtml] = full_html
      else
        name = Avatars.names[index]
        json[:id] = sid
        json[:avatarName] = name
        json[:avatarStartHtml] = start_html(name)
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
