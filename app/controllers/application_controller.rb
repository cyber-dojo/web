require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals

  def katas
    Katas.new(self)
  end

  def kata
    katas[id]
  end

  def avatars
    kata.avatars
  end

  def avatar
    avatars[avatar_name]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    params['id']
  end

  def avatar_name
    params['avatar']
  end

  def was_tag
    params['was_tag'].to_i
  end

  def now_tag
    params['now_tag'].to_i
  end

  def tag
    params['tag'].to_i
  end

  def runner_choice
    params['runner_choice']
  end

  def image_name
    params['image_name']
  end

  def max_seconds
    params['max_seconds'].to_i
  end

  def hidden_filenames
    JSON.parse(params['hidden_filenames'])
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def bind(pathed_filename)
    filename = Rails.root.to_s + pathed_filename
    ERB.new(File.read(filename)).result(binding)
  end

end
