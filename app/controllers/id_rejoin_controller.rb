
class IdRejoinController < ApplicationController

  def drop_down
    # TODO: individual-rejoin
    group = groups[porter.port(id)]
    json = { exists:group.exists? }
    if json[:exists]
      json[:empty] = group.empty?
      json[:avatarPickerHtml] = avatar_picker_html(group.katas)
    end
    render json:json
  end

  private

  def avatar_picker_html(katas)
    @avatar_names = Avatars.names
    @started_ids = Hash[katas.map{ |kata|
      [kata.avatar_name, kata.id]
    }]
    bind('/app/views/id_rejoin/avatar_picker.html.erb')
  end

end
