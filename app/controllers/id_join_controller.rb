
class IdJoinController < ApplicationController

  def show
    @avatar_names = Avatars.names
    @id = id
  end

  def drop_down
    group = groups[mapper.mapped_id(id)]
    json = { exists:group.exists? }
    if json[:exists]
      kata = group.join
      if kata
        json[:id] = kata.id
        json[:avatarName] = kata.avatar_name
      else
        json[:full] = true
      end
    end
    render json:json
  end

end
