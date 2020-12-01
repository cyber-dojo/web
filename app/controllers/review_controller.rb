
class ReviewController < ApplicationController

  def show
    set_bar_info
    if kata.group.id.nil?
      @title = "review:#{kata.id}"
    else
      @title = "review:#{kata.group.id}"
    end
    @was_index = was_index
    @now_index = now_index

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
