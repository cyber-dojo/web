
class IdRejoinController < ApplicationController

  def show
    @from = from
    @possessive = (from == 'individual') ? 'my' : 'our'
  end

  def drop_down
    if from == 'individual'
      json = individual_drop_down_json
    end
    if from == 'group'
      json = group_drop_down_json
    end
    render json:json
  end

  private

  def from
    params[:from]
  end

  def individual_drop_down_json
    # id could be an old id for a group
    group = groups[porter.port(id)]
    json = { exists:group.exists? }
    if json[:exists]
      katas = group.katas
      if katas.size == 1
        json[:kataId] = katas[0].id
        json[:avatarName] = katas[0].avatar_name
      else
        json[:empty] = group.empty?
        json[:avatarPickerHtml] = avatar_picker_html(katas)
      end
      return json
    end
    # id could be a new id ? for a kata
    kata = Katas.new(self)[id]
    json = { exists:kata.exists? }
    if json[:exists]
      json[:kataId] = kata.id
      json[:avatarName] = kata.avatar_name
    end
    json
  end

  def group_drop_down_json
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

  def bind(pathed_filename)
    filename = Rails.root.to_s + pathed_filename
    ERB.new(File.read(filename)).result(binding)
  end

end
