
class IdReviewController < ApplicationController

  def show
    @title = 'id_review'
  end

  def drop_down
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
    bind('/app/views/id_resume/avatar_picker.html.erb')
  end

end
