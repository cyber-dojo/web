
class ReviewController < ApplicationController

  def show
    # Once you are on the review dialog/page
    # all interaction with the web server is via the
    # differ-controller.
    set_bar_info
    @version = kata.schema.version
    if kata.group.id.nil?
      @title = "review:#{kata.id}"
    else
      @title = "review:#{kata.group.id}"
    end
    @avatar_name = kata.avatar_name
    @avatar_index = kata.avatar_index
    @was_index = was_index
    @now_index = now_index
    @filename = params['filename']
    @filename_extension = kata.manifest.filename_extension
    @highlight_filenames = kata.manifest.highlight_filenames
  end

  private

  def set_bar_info
    @id = kata.id
    @group_id = kata.group.id
    @display_name = kata.manifest.display_name
    @exercise = kata.manifest.exercise
  end

end
