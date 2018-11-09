require_relative '../helpers/phonetic_helper'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals
  include PhoneticHelper

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
        kata = groups[id6].katas.find{ |k| k.avatar_name == m[1] }
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

  def katas
    Katas.new(self)
  end

  def kata
    katas[id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def groups
    Groups.new(self)
  end

  def group
    groups[id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # review/show

  def was_tag
    params[:was_tag].to_i
  end

  def now_tag
    params[:now_tag].to_i
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # differ/diff
  # tipper/traffic_light_tip

  def was_index
    params[:was_index].to_i
  end

  def now_index
    params[:now_index].to_i
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # reverter/revert
  # forker/fork
  # tag

  private

  def id
    params[:id]
  end

end
