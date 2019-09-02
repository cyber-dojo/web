require_relative 'kata_v0'
require_relative 'kata_v1'

class Katas

  def initialize(externals)
    @v = Kata_v1.new(externals)
    @externals = externals
  end

  def [](id)
    Kata.new(@externals, id)
  end

  def new_kata(manifest)
    id = @v.create(manifest)
    self[id]
  end

end
