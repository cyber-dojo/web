
class Katas
  include Enumerable

  def initialize(dojo)
    @parent = dojo
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
    storer.kata_exists?(id) ? Kata.new(self, id) : nil
  end

  # modifiers

  def create_kata(manifest)
    storer.create_kata(manifest)
    runner.new_kata(manifest[:image_name], manifest[:id])
  end

  private

  include NearestAncestors
  def storer; nearest_ancestors(:storer); end
  def runner; nearest_ancestors(:runner); end

end
