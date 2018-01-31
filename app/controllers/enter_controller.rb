
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

  def start
    avatar = kata.start_avatar
    full = avatar.nil?
    render json: {
            avatar_name: !full ? avatar.name : '',
                   full:  full,
      start_dialog_html: !full ? start_dialog_html(avatar.name) : '',
       full_dialog_html:  full ? full_dialog_html : ''
    }
  end

  private

  def empty
    avatars.names == []
  end

  def start_dialog_html(avatar_name)
    @avatar_name = avatar_name
    bind('/app/views/enter/start_dialog.html.erb')
  end

  def full_dialog_html
    @all_avatar_names = Avatars.names
    bind('/app/views/enter/full_dialog.html.erb')
  end

  def bind(pathed_filename)
    filename = Rails.root.to_s + pathed_filename
    ERB.new(File.read(filename)).result(binding)
  end

end
