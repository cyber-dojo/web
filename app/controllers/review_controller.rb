
class ReviewController < ApplicationController

  def show
    # Note that once you are on the review dialog/page
    # all interaction with the web server is via the
    # differ-controller.
    ported {
      @kata = kata
      @avatar_name = @kata.avatar_name
      @was_index = was_tag
      @now_index = now_tag
      @filename = filename
      @title = 'review:' + @kata.id
    }
  end

  private

  def was_tag
    tag(:was_tag, '0')
  end

  def now_tag
    tag(:now_tag, '1')
  end

  def tag(param, default)
    n = number_or_nil(params[param] || default)
    n != -1 ? n : @kata.lights[-1].index
  end

  def filename
    params[:filename]
  end

end
