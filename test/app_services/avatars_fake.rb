# frozen_string_literal: true

class AvatarsFake

  def initialize(_externals)
  end

  def sha
    'efadaec738b171c263f9698d02d0677aa2e70f47'
  end

  def ready?
    true
  end

  def names
    NAMES
  end

  private

  NAMES = %w(
    alligator  antelope    bat       bear
    bee        beetle      buffalo   butterfly
    cheetah    crab        deer      dolphin
    eagle      elephant    flamingo  fox
    frog       gopher      gorilla   heron
    hippo      hummingbird hyena     jellyfish
    kangaroo   kingfisher  koala     leopard
    lion       lizard      lobster   moose
    mouse      ostrich     owl       panda
    parrot     peacock     penguin   porcupine
    puffin     rabbit      raccoon   ray
    rhino      salmon      seal      shark
    skunk      snake       spider    squid
    squirrel   starfish    swan      tiger
    toucan     tuna        turtle    vulture
    walrus     whale       wolf      zebra
  )

end
