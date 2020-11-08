# frozen_string_literal: true
require_relative 'kata'

class Katas

  def initialize(externals, params)
    @externals = externals
    @params = params
  end

  def [](id)
    Kata.new(@externals, @params.merge({id:id}))
  end

end
