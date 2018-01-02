
class Katas
  include Enumerable

  def initialize(externals)
    @externals = externals
  end

  # queries

  def each
    (0..255).map{ |n| '%02X' % n }.each do |outer|
      storer.completions(outer).each do |inner|
        yield self[outer + inner]
      end
    end
  end

  def completed(id)
    storer.completed(id)
  end

  def [](id)
    Kata.new(@externals, id)
  end

  # modifiers

  def create_kata(manifest)
    manifest['id'] ||= unique_id
    manifest['created'] ||= time_now
    storer.create_kata(manifest)
    id = manifest['id']
    runner.kata_new(manifest['image_name'], id)
    self[id]
  end

  private

  include TimeNow
  include UniqueId

  def storer
    @externals.storer
  end

  def runner
    @externals.runner
  end

end
