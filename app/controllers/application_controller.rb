require_relative '../helpers/phonetic_helper'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals
  include PhoneticHelper

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def mapped_id
    # See comment below
    if id.size == 10
      id6 = mapper.mapped_id(id)
      url = request.url
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

  def groups
    Groups.new(self)
  end

  def group
    @group ||= groups[id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def katas
    Katas.new(self)
  end

  def kata
    @kata ||= katas[id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def was_files
    files_for(was_index)
  end

  def now_files
    files_for(now_index)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def was_index
    params[:was_index].to_i
  end

  def now_index
    params[:now_index].to_i
  end

  def index
    params[:index].to_i
  end

  def id
    params[:id]
  end

  def files_for(index)
    kata.events[index]
        .files(:with_output)
        .map{ |filename,file| [filename, file['content']] }
        .to_h
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - -
# mapped()
# - - - - - - - - - - - - - - - - - - - - - - - -
# cyber-dojo was originally designed for group practice-sessions.
# An individual practice-session was just a group
# practice-session with a single avatar.
# So originally, edit/ URLs always looked like this...
#    http://cyber-dojo.org/kata/edit/hVU93Kj8rq?avatar=tiger
# There was a 10-digit id (hVU93Kj8rq) and an avatar name (tiger).
#
# cyber-dojo now properly supports both group practice-sessions
# and individual practice sessions, but the URLs always look like this
#    http://cyber-dojo.org/kata/edit/mFL6se
# and use 6-digit ids (mFL6se) and never contain an avatar name.
# If mFL6se is in a group practice-session an avatar will be visible.
# If mFL6se is an individual practice-session an avatar won't be visible.
#
# The job of mapped() is to redirect old 10-digit ids to new 6-digit ids.
# For example
#    http://cyber-dojo.org/kata/edit/hVU93Kj8rq?avatar=tiger
# to
#    http://cyber-dojo.org/kata/edit/mFL6se
#
# Of course, there were URLs that used 10-digit ids and did not contain
# an avatar name, for the dashboard and diff/review for example.
#
# Examples of mapped() URL redirections...
#
#     dashboard/show/1F00C1BFC8
# --> dashboard/show/2M0Ry7?
#
#     kata/edit/1F00C1BFC8?avatar=turtle
# --> kata/edit/2M0Ry7?
#
#     review/show/1F00C1BFC8?avatar=turtle&was_tag=2&now_tag=3
# --> review/show/2M0Ry7?was_tag=2&now_tag=3
# --> review/show/2M0Ry7?was_index=2&now_index=3
# - - - - - - - - - - - - - - - - - - - - - - - -
