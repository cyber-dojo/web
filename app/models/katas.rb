require_relative 'kata_v0'

class Katas

  def initialize(externals)
    @v = Kata_v0.new(externals)
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
