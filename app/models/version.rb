require_relative 'kata_v0'
require_relative 'group_v0'

class Version

  def initialize(externals, n)
    if n === 0
      @group ||= Group_v0.new(externals)
      @kata  ||= Kata_v0.new(externals)
    end
  end

  attr_reader :group, :kata

end
