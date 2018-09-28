
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

  def initialize(externals, gid)
    @externals = externals
    @joined = grouper.joined(gid)
    @ids = Hash[@joined.map{ |index,id|
      name = names[index.to_i]
      [name,id]
    }]
    @started = Hash[@joined.map{ |index,id|
      name = names[index.to_i]
      [name, self[name]]
    }]
  end

  # queries

  def started
    @started
  end

  def each(&block)
    started.values.each(&block)
  end

  def [](name)
    Avatar.new(@externals, @ids[name], name)
  end

  def active
    select(&:active?)
  end

  def names
    collect(&:name).sort
  end

  private # = = = = = = = = =

  def katas
    Katas.new(@externals)
  end

  def grouper
    @externals.grouper
  end

end
