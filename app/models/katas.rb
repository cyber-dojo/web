require_relative 'kata'

class Katas

  def initialize(externals)
    @externals = externals
  end

  def [](id)
    Kata.new(@externals, id)
  end

  def new_kata(manifest)
    n = manifest['version'] || 0
    id = Version.new(@externals, n).kata.create(manifest)
    self[id]
  end

end
