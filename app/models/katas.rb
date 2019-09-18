require_relative 'kata'
require_relative 'schema'

class Katas

  def initialize(externals)
    @externals = externals
  end

  def [](id)
    Kata.new(@externals, id)
  end

  def new_kata(manifest)
    version = manifest['version'] || 0
    id = Schema.new(@externals, version).kata.create(manifest)
    self[id]
  end

end
