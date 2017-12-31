
module EnterWorker # mix-in

  module_function

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

  def resume_dialog_html
    @id = id
    @started_avatar_names = avatars.names
    @all_avatar_names = Avatars.names
    bind('/app/views/enter/resume_dialog.html.erb')
  end

  def bind(pathed_filename)
    filename = Rails.root.to_s + pathed_filename
    ERB.new(File.read(filename)).result(binding)
  end

end
