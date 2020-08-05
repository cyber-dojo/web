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

  def index
    params[:index].to_i
  end

  def was_index
    @was_index ||= value_of(:was_index)
    # Avoid extra saver-call for diff(-1,-1)
    @now_index = @was_index if params[:was_index].to_i === -1
    @was_index
  end

  def now_index
    @now_index ||= value_of(:now_index)
    # Avoid extra saver-call for diff(-1,-1)
    @was_index = @now_index if params[:now_index].to_i === -1
    @now_index
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
