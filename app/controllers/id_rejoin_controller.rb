
class IdRejoinController < ApplicationController

  def drop_down
    @id = params['id'] = grouper.id_completed(id)
    json = { exists: @id != '' }
    if json[:exists]
      joined = grouper.joined(@id)
      json[:empty] = (joined.count == 0)
      json[:avatarPickerHtml] = avatar_picker_html(joined)
    end
    render json:json
  end

  private

  def avatar_picker_html(joined)
    @all_avatar_names = Avatars.names
    @started_avatars = {}
    joined.each do |index,id|
      name = Avatars.names[index.to_i]
      @started_avatars[name] = id
    end
    bind('/app/views/id_rejoin/avatar_picker.html.erb')
  end

end
