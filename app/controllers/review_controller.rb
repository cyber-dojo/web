
class ReviewController < ApplicationController

  def show
    # Once you are on the review dialog/page
    # all interaction with the web server is via the
    # differ-controller.
    mapped_id {
      @title = 'review:' + kata.id
      @id = kata.id
      @avatar_name = kata.avatar_name
      @was_index = was_index
      @now_index = now_index
      @filename = filename
    }
  end

  private

  def filename
    params[:filename]
  end

end
