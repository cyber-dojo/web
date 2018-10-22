require_relative '../helpers/id_helper'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals
  include IdHelper

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def ported
    # TODO: aim to drop avatar from URL
    if id.size == 10
      redirect_to request.url.sub(id, porter.port(id))
    else
      yield
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    params[:id]
  end

  def katas
    Katas.new(self)
  end

  def kata
    if avatar_name != ''
      groups[id].avatars[avatar_name].kata
    else
      katas[id]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def groups
    Groups.new(self)
  end

  def avatar_name
    # TODO: aim to have no avatars on URLs
    params[:avatar] || ''
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def was_tag
    number_or_nil(params[:was_tag])
  end

  def now_tag
    number_or_nil(params[:now_tag])
  end

  def tag
    number_or_nil(params[:tag])
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

=begin

  private

  def kata_id
    # dashboard/show/ID
    # ...does not have avatar and ID == group-id
    # kata/edit/ID?avatar=tuna
    # ...does have avatar and ID = group-id
    # kata/edit/ID
    # ...does not have avatar and ID = kata-id  NEW

    param = params[:kata_id]
    if param
      # cached for KataController.run_tests()
      param
    elsif avatar_name != ''
      # group practice-session
      groups[id].avatars[avatar_name].kata.id
    else
      # individual practice-session
      id
    end
  end
=end

end
