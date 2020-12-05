# frozen_string_literal: true
require_relative 'app_services_test_base'

class ExternalsTest < AppServicesTestBase

  def self.hex_prefix
    '2aP'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2sK',
  'default http-proxy adapter classes' do
    assert model.is_a?(ModelService)
    assert runner.is_a?(RunnerStub)
    assert saver.is_a?(SaverService)
  end

end
