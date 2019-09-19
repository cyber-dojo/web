require_relative 'app_services_test_base'
require_relative 'ragger_stub'

class RaggerStubTest < AppServicesTestBase

  def self.hex_prefix
    '9B9'
  end

  def hex_setup
    set_ragger_class('RaggerStub')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3C0', 'stub_colour' do
    ragger.stub_colour('green')
    assert_equal 'green', ragger.colour('','','','',0)
  end

end
