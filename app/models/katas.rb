require_relative '../../lib/time_now'

class Katas

  def initialize(externals)
    @externals = externals
  end

  # queries

  def completed(id)
    storer.completed(id)
  end

  def [](id)
    Kata.new(@externals, id)
  end

  # modifier

  def create_kata(manifest)
    manifest['created'] ||= time_now
    id = storer.create_kata(manifest)
    runner.kata_new(manifest['image_name'], id)
    self[id]
  end

  private

  include TimeNow

  def storer
    @externals.storer
  end

  def runner
    @externals.runner
  end

end
