require_relative '../../lib/time_now'
require_relative 'base58'

class Katas
  include Enumerable

  def initialize(externals)
    @externals = externals
  end

  # queries

  def each
    # slow...
    Base58.alphabet.chars.each do |c1|
      Base58.alphabet.chars.each do |c2|
        outer = c1 + c2
        storer.completions(outer).each do |inner|
          yield self[outer + inner]
        end
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
