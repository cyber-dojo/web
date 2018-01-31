
class ResumeController < ApplicationController

  def show
    @title = 'resume'
  end

  def check
    # TODO: if there is no completion
    # storer's kata.completed(id) could return ''
    # then I would not need to call kata.exists?
    # which does another round-trip to the storer
    @id = params['id'] = katas.completed(id.upcase)
    exists = kata.exists?
    render json: {
      exists: exists,
      html: exists ? dialog_html : ''
    }
  end

  private

  def dialog_html
    @all_avatar_names = Avatars.names
    @started_avatar_names = avatars.names
    bind('/app/views/resume/dialog.html.erb')
  end

  def bind(pathed_filename)
    filename = Rails.root.to_s + pathed_filename
    ERB.new(File.read(filename)).result(binding)
  end

end
