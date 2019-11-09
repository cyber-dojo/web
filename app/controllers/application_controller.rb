require_relative '../services/externals'
require_relative '../helpers/phonetic_helper'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals
  include PhoneticHelper

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def groups
    @groups ||= Groups.new(self, params)
  end

  def group
    @group ||= Group.new(self, params)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def katas
    @katas ||= Katas.new(self, params)
  end

  def kata
    @kata ||= Kata.new(self, params)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    params[:id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def files_for(index)
    kata.events[index]
        .files(:with_output)
        .map{ |filename,file| [filename, file['content']] }
        .to_h
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def index
    params[:index].to_i
  end

  def was_index
    value_of(:was_index)
  end

  def now_index
    value_of(:now_index)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def value_of(sym)
    value = params[sym].to_i
    if value === -1
      value = kata.events[-1].index
    end
    value
  end

end
