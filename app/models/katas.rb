
class Katas
  include Enumerable

  def initialize(dojo)
    @parent = dojo
  end

  # queries

  attr_reader :parent

  def path
    storer.path
  end

  def each(&block)
    storer.each(&block)
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
  end

  private

  include ExternalParentChainer

end
