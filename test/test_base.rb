require_relative 'test_domain_helpers'
require_relative 'test_external_helpers'
require_relative 'test_hex_id_helpers'
require 'minitest/autorun'

class TestBase < MiniTest::Test

  def self.v_tests(versions, hex_prefix, *lines, &block)
    versions.each do |version|
      v_lines = ["<version=#{version}>"] + lines
      test(hex_prefix + version.to_s, *v_lines, &block)
    end
  end

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

end
