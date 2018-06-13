require_relative '../../lib/phonetic_alphabet'

class ReviewController < ApplicationController

  def show
    # Note that once you are on the review dialog/page
    # all interaction with the web server is via the
    # differ-controller.
    @kata = kata
    @avatar_name = params[:avatar] || kata.avatars.active.map(&:name).sort[0]
    @avatar = avatars[@avatar_name]
    @was_tag = was_tag
    @now_tag = now_tag
    @filename = filename
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
    n != -1 ? n : @avatar.lights[-1].number
  end

  def filename
    params[:filename]
  end

end
