
class Katas

  def initialize(externals)
    @externals = externals
  end

  def [](id)
    Kata.new(@externals, id)
  end

  def new_kata(manifest)
    id = saver.kata_create(manifest)
    self[id]
  end

  private

  def saver
    @externals.saver
  end

end
