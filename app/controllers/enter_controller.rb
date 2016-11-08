
class EnterController < ApplicationController

  def show
    @title = 'enter'
    @id = id || ''
  end

  def check
    full_id = katas.completed(id)
    render json: {
      exists: !katas[full_id].nil?,
      full_id: full_id
    }
  end

  def start
    avatar = kata.start_avatar
    full = avatar.nil?
    unless full
      runner.new_avatar(kata.id, avatar.name)
      args = []
      args << kata.image_name
      args << kata.id
      args << avatar.name
      args << (delted_filenames=[])
      args << (changed_files=kata.visible_files)
      args << (max_seconds=10)
      runner.run(*args)
    end
    render json: {
            avatar_name: !full ? avatar.name : '',
                   full:  full,
      start_dialog_html: !full ? start_dialog_html(avatar.name) : '',
       full_dialog_html:  full ? full_dialog_html : ''
    }
  end

  def continue
    render json: {
      empty: empty,
       html: continue_dialog_html
    }
  end

  private

  include EnterWorker

end
