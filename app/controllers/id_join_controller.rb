
class IdJoinController < ApplicationController

  # Only for a group practice-session
  def drop_down
    group = groups[porter.port(id)]
    json = { exists:group.exists? }
    if json[:exists]
      kata = group.join
      json[:full] = kata.nil?
      if json[:full]
        json[:fullHtml] = full_html
      else
        json[:id] = kata.id
        json[:avatarName] = kata.avatar_name
      end
    end
    render json:json
  end

  private

  def full_html
    @avatar_names = Avatars.names
    bind('/app/views/id_join/full.html.erb')
  end

end
