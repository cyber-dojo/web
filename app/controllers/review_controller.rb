
class ReviewController < ApplicationController

  def show
    set_bar_info
    @title = "review:#{kata.id}"
    @was_index = was_index
    @now_index = now_index

    @filename_extension = kata.manifest.filename_extension
    @highlight_filenames = kata.manifest.highlight_filenames
  end

  private

  def set_bar_info
    @id = kata.id
    @manifest = kata.manifest
  end

end
