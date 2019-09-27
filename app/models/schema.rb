# frozen_string_literal: true

require_relative 'group_v0'
require_relative 'group_v1'
require_relative 'kata_v0'
require_relative 'kata_v1'

class Schema

  def initialize(externals, version)
    @group = GROUPS[version].new(externals)
    @kata = KATAS[version].new(externals)
    @version = version
  end

  attr_reader :group, :kata, :version

  private

  GROUPS = [ Group_v0, Group_v1 ]
  KATAS = [ Kata_v0, Kata_v1 ]

end

# TODO: Kata.event(index) is returning a Hash and not an
# Event object. Does schema need [group,kata,event] triple?
