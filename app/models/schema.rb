# frozen_string_literal: true
require_relative 'kata_v0'
require_relative 'kata_v1'

class Schema

  def initialize(externals, version)
    @kata = KATAS[version].new(externals)
    @version = version
  end

  attr_reader :kata, :version

  private

  KATAS = [ Kata_v0, Kata_v1 ]

end
