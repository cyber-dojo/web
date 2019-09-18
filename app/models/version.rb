require_relative 'group_v0'
require_relative 'group_v1'
require_relative 'kata_v0'
require_relative 'kata_v1'

class Version

  def initialize(externals, n)
    @group = GROUPS[n].new(externals)
    @kata = KATAS[n].new(externals)
    @n = n
  end

  attr_reader :group, :kata

  def number
    @n
  end

  private

  GROUPS = [ Group_v0, Group_v1 ]
  KATAS = [ Kata_v0, Kata_v1 ]

end
