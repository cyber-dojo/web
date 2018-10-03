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

  def kata
    katas[kata_id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def groups
    Groups.new(self)
  end

  def group
    if avatar_name != '' # dashboard worker bypasses this...
      groups[id]         # this works for differ-diff
    else
      nil
    end
    # dashboard/show/ID
    # ...does not have avatar and ID == group-id
    # kata/edit/ID?avatar=tuna
    # ...does have avatar and ID = group-id
    # kata/edit/ID
    # ...does not have avatar and ID = kata-id  NEW
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

  def bind(pathed_filename)
    filename = Rails.root.to_s + pathed_filename
    ERB.new(File.read(filename)).result(binding)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def number_or_nil(string)
    num = string.to_i
    num if num.to_s == string
  end

  private

  def kata_id
    if avatar_name != ''
      # group practice-session
      groups[id].avatars[avatar_name].kata.id
    else
      # individual practice-session
      id
    end
  end

end
