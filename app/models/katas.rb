
class Katas
  include Enumerable

  def initialize(parent)
    @parent = parent
  end

  # queries

  attr_reader :parent

  def each
    (0..255).map{ |n| '%02X' % n }.each do |outer|
      storer.completions(outer).each do |inner|
        yield Kata.new(self, outer + inner)
      end
    end
  end

  def completed(id)
    storer.completed(id)
  end

  def [](id)
    Kata.new(self, id)
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

  include NearestAncestors
  include TimeNow
  include UniqueId

  def storer
    nearest_ancestors(:storer)
  end

  def runner
    nearest_ancestors(:runner)
  end

end
