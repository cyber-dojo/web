
class IdRejoinController < ApplicationController

  def show
    @from = from
  end

  def drop_down
    if from == 'individual'
      json = individual_drop_down
    end
    if from == 'group'
      json = group_drop_down
    end
    render json:json
  end

  private

  def from
    params[:from]
  end

  def individual_drop_down
    # id could be old id for a group
    #    if it has a single avatar
    #      go straight to the avatar using its kata-id
    #    if it has several avatars
    #      ???
    

    # id could be new id for a kata
    #    go straight to the kata
    kata = katas[id]
    json = { exists:kata.exists? }
    if json[:exists]
      json[:kataId] = id
    end
    json
  end

  def group_drop_down
    group = groups[porter.port(id)]
    json = { exists:group.exists? }
    if json[:exists]
      json[:empty] = group.empty?
      json[:avatarPickerHtml] = avatar_picker_html(group.katas)
    end
    json
  end

  def avatar_picker_html(katas)
    @avatar_names = Avatars.names
    @started_ids = Hash[katas.map{ |kata|
      [kata.avatar_name, kata.id]
    }]
    bind('/app/views/id_rejoin/avatar_picker.html.erb')
  end

end
