
class DojoController < ApplicationController

  def index
    @title = 'Home'
    @id = id
  end

  def button_dialog
    name = params[:id]
    render :partial => "/dojo/dialog_#{name}",
           :layout => false
  end

  #------------------------------------------------

  def valid_id
    paas.session('dojo:valid_id') do
      kata = dojo.katas[id]
      exists = params[:id].length >= 6 && kata.exists?
      started = exists ? kata.avatars.entries.length : 0
      render :json => {
        :exists => exists,
        :started => started
      }
    end
  end

  #------------------------------------------------

  def start_json
    paas.session('dojo:start_json') do
      kata = dojo.katas[id]
      exists = kata.exists?
      avatar = (exists ? kata.start_avatar : nil)
      full = exists && avatar.nil?
      start_html = exists && avatar ? start_dialog_html(avatar.name) : ''
      full_html = full ? full_dialog_html() : ''
      render :json => {
        :exists => exists,
        :avatar_name => avatar ? avatar.name : nil,
        :full => full,
        :start_dialog_html => start_html,
        :full_dialog_html => full_html
      }
    end
  end

  def start_dialog_html(avatar_name)
    @avatar_name = avatar_name
    bind('/app/views/dojo/start_dialog.html.erb')
  end

  def full_dialog_html()
    @all_avatar_names = Avatar.names
    bind('/app/views/dojo/full_dialog.html.erb')
  end

  #------------------------------------------------

  def resume_json
    paas.session('dojo:resume_json') do
      kata = dojo.katas[id]
      exists = kata.exists?
      started_avatar_names = exists ? kata.avatars.collect{|avatar| avatar.name} : [ ]
      empty = (started_avatar_names == [ ])
      render :json => {
        :exists => exists,
        :empty => empty,
        :resume_dialog_html => (exists ? resume_dialog_html(kata, started_avatar_names) : '')
      }
    end
  end

  def resume_dialog_html(kata, started_avatar_names)
    paas.session('dojo:resume_json') do
      @kata = kata
      @started_avatar_names = started_avatar_names
      @all_avatar_names = Avatars.names
      bind('/app/views/dojo/resume_dialog.html.erb')
    end
  end

end
