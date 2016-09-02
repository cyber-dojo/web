
class Katas
  include Enumerable

  def initialize(dojo)
    @parent = dojo
  end

  # queries

  attr_reader :parent

  def each
    hex_chars.each_char do |outer|
      hex_chars.each_char do |inner|
        storer.ids_for(outer + inner).each do |eight|
          yield Kata.new(self, outer + inner + eight)
        end
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
  end

  private

  include ExternalParentChainer

  def hex_chars
    '0123456789ABCDEF'
  end

end
