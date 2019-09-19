require_relative 'app_services_test_base'
require_relative 'http_json_request_packer_not_json_stub'
require_relative '../../app/services/avatars_service'

class AvatarsServiceTest < AppServicesTestBase

  def self.hex_prefix
    '6B9'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequestPackerNotJsonStub)
    error = assert_raises(AvatarsService::Error) { avatars.sha }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A8',
  'smoke test sha' do
    assert_sha avatars.sha
  end

  test '3A9',
  'smoke test ready?' do
    assert avatars.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AC',
  'smoke test names' do
    assert_equal expected_names, avatars.names
  end

  def expected_names
    %w(
      alligator
      antelope
      bat
      bear
      bee
      beetle
      buffalo
      butterfly
      cheetah
      crab
      deer
      dolphin
      eagle
      elephant
      flamingo
      fox
      frog
      gopher
      gorilla
      heron
      hippo
      hummingbird
      hyena
      jellyfish
      kangaroo
      kingfisher
      koala
      leopard
      lion
      lizard
      lobster
      moose
      mouse
      ostrich
      owl
      panda
      parrot
      peacock
      penguin
      porcupine
      puffin
      rabbit
      raccoon
      ray
      rhino
      salmon
      seal
      shark
      skunk
      snake
      spider
      squid
      squirrel
      starfish
      swan
      tiger
      toucan
      tuna
      turtle
      vulture
      walrus
      whale
      wolf
      zebra
    )
  end

end
