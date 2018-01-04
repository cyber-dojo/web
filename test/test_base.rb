require_relative 'test_domain_helpers'
require_relative 'test_external_helpers'
require_relative 'test_hex_id_helpers'
require 'minitest/autorun'

class TestBase < MiniTest::Test

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

end
