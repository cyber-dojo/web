
class IdRejoinController < ApplicationController

  def show
    @id = id
    @from = from
    @possessive = (from === 'individual') ? 'my' : 'our'
  end

  def rejoin
    if from === 'individual'
      json = individual_rejoin_json
    end
    if from === 'group'
      json = group_rejoin_json
    end
    render json:json
  end

  def drop_down # deprecated
    rejoin
  end

  private

  def from
    params[:from]
  end

  def individual_rejoin_json
    # rejoin group session
    json = { exists:group.exists? }
    if json[:exists]
      katas = group.katas
      if katas.size === 1
        json[:kataId] = katas[0].id
        json[:avatarName] = katas[0].avatar_name
        json[:avatarIndex] = katas[0].avatar_index
      else
        json[:empty] = group.empty?
        json[:avatarPickerHtml] = avatar_picker_html(katas)
      end
      return json
    end
    # rejoin individual session
    json = { exists:kata.exists? }
    if json[:exists]
      json[:kataId] = kata.id
      json[:avatarName] = kata.avatar_name
      json[:avatarIndex] = kata.avatar_index
    end
    json
  end

  def group_rejoin_json
    json = { exists:group.exists? }
    if json[:exists]
      json[:empty] = group.empty?
      json[:avatarPickerHtml] = avatar_picker_html(group.katas)
    end
    json
  end

  def avatar_picker_html(katas)
    @avatar_names = Avatars.names
    @started_ids = katas.map{ |kata|
      [kata.avatar_name, kata.id]
    }.to_h
    bind('/app/views/id_rejoin/avatar_picker.html.erb')
  end

  def bind(pathed_filename)
    filename = Rails.root.to_s + pathed_filename
    ERB.new(File.read(filename)).result(binding)
  end

end
