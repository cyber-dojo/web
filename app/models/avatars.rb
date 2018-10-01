
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

  def initialize(externals, id)
    @externals = externals
    @id = id
    names = []
    @ids = Hash[grouper.joined(id).map{ |index,id|
      name = Avatars.names[index.to_i]
      names << name
      [name,id]
    }]
    @all = names.map{ |name| self[name] }
  end

  def each(&block)
    @all.each(&block)
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

  private

  def grouper
    @externals.grouper
  end

end
