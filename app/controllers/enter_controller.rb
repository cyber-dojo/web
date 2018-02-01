
class EnterController < ApplicationController

  def show
    @title = 'enter'
  end

  def check
    full_id = katas.completed(id.upcase)
    render json: {
      exists: full_id.length == 10,
      full_id: full_id
    }
  end

  def checked_start
    @id = params['id'] = katas.completed(id.upcase)
    json = { exists: kata.exists? }
    if json[:exists]
      avatar = kata.start_avatar
      json[:full] = avatar.nil?
      if json[:full]
        json[:fullHtml] = full_html
      else
        json[:id] = @id
        json[:avatarName] = avatar.name
        json[:avatarStartHtml] = start_html(avatar.name)
      end
    end
    render json:json
  end

  def start
    avatar = kata.start_avatar
    full = avatar.nil?
    render json: {
            avatar_name: !full ? avatar.name : '',
                   full:  full,
      start_dialog_html: !full ? start_html(avatar.name) : '',
       full_dialog_html:  full ? full_html : ''
    }
  end

  private

  def start_html(avatar_name)
    @avatar_name = avatar_name
    bind('/app/views/enter/start.html.erb')
  end

  def full_html
    @all_avatar_names = Avatars.names
    bind('/app/views/enter/full.html.erb')
  end

  def bind(pathed_filename)
    filename = Rails.root.to_s + pathed_filename
    ERB.new(File.read(filename)).result(binding)
  end

end
