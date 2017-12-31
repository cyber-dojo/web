
class Avatars
  include Enumerable

  def self.names
    %w(alligator antelope     bat       bear
       bee       beetle       buffalo   butterfly
       cheetah   crab         deer      dolphin
       eagle     elephant     flamingo  fox
       frog      gopher       gorilla   heron
       hippo     hummingbird  hyena     jellyfish
       kangaroo  kingfisher   koala     leopard
       lion      lizard       lobster   moose
       mouse     ostrich      owl       panda
       parrot    peacock      penguin   porcupine
       puffin    rabbit       raccoon   ray
       rhino     salmon       seal      shark
       skunk     snake        spider    squid
       squirrel  starfish     swan      tiger
       toucan    tuna         turtle    vulture
       walrus    whale        wolf      zebra
    )
  end

  def initialize(kata)
    @kata = kata
  end

  # queries

  attr_reader :kata

  def parent
    kata
  end

  def started
    names = storer.started_avatars(kata.id)
    Hash[names.map { |name|
      [name, Avatar.new(kata, name)]
    }]
  end

  def each(&block)
    started.values.each(&block)
  end

  def [](name)
    started[name]
  end

  def active
    select(&:active?)
  end

  def names
    collect(&:name).sort
  end

  private

  include NearestAncestors

  def storer
    nearest_ancestors(:storer)
  end

end
