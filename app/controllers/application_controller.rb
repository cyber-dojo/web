require_relative '../helpers/phonetic_helper'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals
  include PhoneticHelper

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def ported
    if id.size == 10
      url = request.url
      id6 = porter.port(id)
      if m = /#{id}\?avatar=([a-z]*)&?/.match(url)
        kata = groups[id6].katas.find{ |k| k.avatar_name == m[1] }
        url6 = url.sub(m.to_s, kata.id+'?')
      else
        url6 = url.sub(id, id6)
      end
      url6 = url6.sub('was_tag', 'was_index')
      url6 = url6.sub('now_tag', 'now_index')
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
    @cached_kata ||= katas[id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def groups
    Groups.new(self)
  end

  def group
    @cached_group ||= groups[id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # review/show
  # differ/diff
  # tipper/traffic_light_tip

  def was_index
    was = params[:was_index].to_i
    if was == -1
      was = kata.events.size - 1
    end
    was
  end

  def now_index
    now = params[:now_index].to_i
    if now == -1
      now = kata.events.size - 1
    end
    now
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # reverter/revert
  # forker/fork

  def index
    params[:index].to_i
  end

  private

  def id
    params[:id]
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - -
# ported()
#
# cyber-dojo is designed for group practice-sessions.
# In this 'mode' URLs used to look like this...
#    http://cyber-dojo.org/kata/edit/hVU93Kj8rq?avatar=tiger
# The hVU93Kj8rq was a 10-digit group-id
# and the avatar=tiger was your animal inside this group
# Now, ported() will redirect this URLs to something like this...
#    http://cyber-dojo.org/kata/edit/mFL6se
# where mFL6se is the 6-digit kata-id
#
# cyber-dojo can also be used for individual practice-sessions.
# In this 'mode' URLs also look like this...
#   http://cyber-dojo.org/kata/edit/ym04AU
# The ym04AU is a 6-digit kata-id with no associated avatar-name.
#
# Examples of ported() URL redirections...
#
#     dashboard/show/1F00C1BFC8
# --> dashboard/show/2M0Ry7?

#     kata/edit/1F00C1BFC8?avatar=turtle
# --> kata/edit/2M0Ry7?

#     review/show/1F00C1BFC8?avatar=turtle&was_tag=2&now_tag=3
# --> review/show/2M0Ry7?was_tag=2&now_tag=3
# --> review/show/2M0Ry7?was_index=2&now_index=3
