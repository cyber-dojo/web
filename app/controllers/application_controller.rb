require_relative '../services/externals'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata
    @kata ||= Kata.new(self, params)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    params[:id]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def was_index
    @was_index ||= value_of(:was_index)
    @now_index = @was_index if params[:was_index].to_i === -1
    @was_index
  end

  def now_index
    @now_index ||= value_of(:now_index)
    @was_index = @now_index if params[:now_index].to_i === -1
    @now_index
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def value_of(sym)
    value = (params[sym] || -1).to_i
    if value === -1
      value = kata.events[-1].index
    end
    value
  end

end
