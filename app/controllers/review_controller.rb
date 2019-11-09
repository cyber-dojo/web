
class ReviewController < ApplicationController

  def show
    # Once you are on the review dialog/page
    # all interaction with the web server is via the
    # differ-controller.
    set_footer_info
    @version = kata.schema.version
    @title = 'review:' + kata.id
    @avatar_index = kata.avatar_index
    @avatar_name = kata.avatar_name
    @was_index = was_index
    @now_index = now_index
    @filename = params['filename']
    @filename_extension = kata.manifest.filename_extension
    @highlight_filenames = kata.manifest.highlight_filenames
  end

  private

  def set_footer_info
    @id = kata.id
    @display_name = kata.manifest.display_name
    @exercise = kata.manifest.exercise
  end

end
