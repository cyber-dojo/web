require_relative '../services/externals'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals

  def kata
    @kata ||= Kata.new(self, params)
  end

end
