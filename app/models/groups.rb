# frozen_string_literal: true
require_relative 'group'

class Groups

  def initialize(externals, params)
    @externals = externals
    @params = params
  end

  def [](id)
    Group.new(@externals, @params.merge({id:id}))
  end

end
