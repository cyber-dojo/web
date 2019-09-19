require_relative 'app_services_test_base'
require_relative 'saver_dummy'

class SaverDummyTest < AppServicesTestBase

  def self.hex_prefix
    'B0C'
  end

  def hex_setup
    set_saver_class('SaverDummy')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '94E',
  'all calls are logged to /tmp/ file based on test ID' do
    saver.any_call('chub', 42)
    content = IO.read("/tmp/cyber-dojo-#{hex_test_kata_id}.json")
    logged = JSON.parse!(content)
    assert_equal [ 'any_call', 'chub', 42 ], logged
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '94F',
  'multiple calls are logged to successive lines' do
    saver.coarse('fishing')
    saver.spey('casting')
    content = IO.read("/tmp/cyber-dojo-#{hex_test_kata_id}.json")
    lines = content.lines
    assert_equal [ 'coarse', 'fishing' ], JSON.parse!(lines[0])
    assert_equal [ 'spey', 'casting' ], JSON.parse!(lines[1])
  end

end
