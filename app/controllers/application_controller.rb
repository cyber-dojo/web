require_relative '../helpers/id_helper'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals
  include IdHelper

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    params['id']
  end

  def katas
    Katas.new(self)
  end

  def kata_id
    param = params['kata_id']
    if param
      # cached for kata/edit run_tests()
      param
    elsif avatar_name != ''
      # group practice-session
      joined = grouper.joined(id)
      index = Avatars.names.index(avatar_name)
      joined[index.to_s]
    else
      # individual practice-session
      id
    end
  end

  def kata
    katas[kata_id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def groups
    Groups.new(self)
  end

  def group
    groups[id]
  end

  def avatar_name
    params['avatar'] || ''
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def was_tag
    number_or_nil(params['was_tag'])
  end

  def now_tag
    number_or_nil(params['now_tag'])
  end

  def tag
    number_or_nil(params['tag'])
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

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

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def number_or_nil(string)
    num = string.to_i
    num if num.to_s == string
  end

end
