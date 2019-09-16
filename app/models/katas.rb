require_relative 'version'
require_relative 'kata'

class Katas

  def initialize(externals, n = 0)
    @externals = externals
    @v = Version.new(@externals, n)
  end

  def [](id)
    Kata.new(@externals, id, @v)
  end

  def new_kata(manifest)
    id = @v.kata.create(manifest)
    self[id]
  end

end
