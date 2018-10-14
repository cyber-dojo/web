
class IdRejoinController < ApplicationController

  def drop_down
    # TODO: individual-rejoin
    @id = id
    joined = saver.group_joined(@id)
    json = { exists:!joined.nil? }
    if json[:exists]
      indexes = joined.keys
      json[:empty] = (indexes == [])
      json[:avatarPickerHtml] = avatar_picker_html(indexes)
    end
    render json:json
  end

  private

  def avatar_picker_html(indexes)
    @all_avatar_names = Avatars.names
    @started_avatar_names = indexes.map do |index|
      Avatars.names[index.to_i]
    end
    bind('/app/views/id_rejoin/avatar_picker.html.erb')
  end

end
