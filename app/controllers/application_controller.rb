require_relative '../helpers/id_helper'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals
  include IdHelper

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def ported
    #     dashboard/show/1F00C1BFC8
    # --> dashboard/show/2M0Ry7?

    #     kata/edit/1F00C1BFC8?avatar=lion
    # --> kata/edit/2M0Ry7?

    #     review/show/1F00C1BFC8?avatar=lion&was_tag=2&now_tag=3
    # --> review/show/2M0Ry7?was_tag=2&now_tag=3
    if id.size == 10
      url = request.url
      id6 = porter.port(id)
      if m = /#{id}\?avatar=([a-z]*)&?/.match(url)
        kata = groups[id6].katas.detect{ |k| k.avatar_name == m[1] }
        url6 = url.sub(m.to_s, kata.id+'?')
      else
        url6 = url.sub(id, id6)
      end
      redirect_to url6
    else
      yield
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata
    katas[id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def group
    groups[id]
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

  def katas
    # Used in runner_service
    Katas.new(self)
  end

  private

  def id
    params[:id]
  end

  def groups
    Groups.new(self)
  end

  def number_or_nil(string)
    num = string.to_i
    num if num.to_s == string
  end

end
