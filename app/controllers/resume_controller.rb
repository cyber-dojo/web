
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
    json = { exists: kata.exists? }
    if json[:exists]
      json[:empty] = kata.avatars.started.count == 0
      json[:avatarPickerHtml] = avatar_picker_html
    end
    render json:json
  end

  private

  def avatar_picker_html
    @all_avatar_names = Avatars.names
    @started_avatar_names = avatars.names
    bind('/app/views/resume/avatar_picker.html.erb')
  end

  def bind(pathed_filename)
    filename = Rails.root.to_s + pathed_filename
    ERB.new(File.read(filename)).result(binding)
  end

end
