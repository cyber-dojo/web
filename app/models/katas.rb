require_relative '../../lib/time_now'

class Katas

  def initialize(externals)
    @externals = externals
  end

  # queries

  def [](id)
    Kata.new(@externals, id)
  end

  # modifier

  def kata_create(manifest)
    manifest['created'] ||= time_now
    id = singler.create(manifest)
    image_name = manifest['image_name']
    starting_files = manifest['visible_files']
    runner.kata_new(image_name, id, starting_files)
    self[id]
  end

  private

  include TimeNow

  def singler
    @externals.singler
  end

  def runner
    @externals.runner
  end

end
