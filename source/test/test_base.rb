require_relative 'test_domain_helpers'
require_relative 'test_external_helpers'
require_relative 'test_hex_id_helpers'
require 'minitest/autorun'

class TestBase < Minitest::Test

  def self.v_tests(versions, hex_prefix, *lines, &block)
    versions.each do |version|
      v_lines = ["<version=#{version}>"] + lines
      test(hex_prefix + version.to_s, *v_lines, &block)
    end
  end

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

  Minitest.after_run do
    slow = $timings.select{ |_name,secs| secs > 0.000 }
    sorted = slow.sort_by{ |name,secs| -secs }.to_h
    size = sorted.size < 5 ? sorted.size : 5
    puts
    puts "Slowest #{size} tests are..." if size != 0
    sorted.each_with_index do |(name,secs),index|
      puts "%3.4f - %-72s" % [secs,name]
      break if index == size
    end
  end

  Minitest.after_run do
    # complain about any unfound test-id args
    unseen_arg = lambda { |arg|
      $seen_ids.none? { |id|
        id.include?(arg)
      }
    }
    unseen_args = $args.find_all { |arg|
      unseen_arg.call(arg)
    }
    unless unseen_args == []
      message = 'the following test id arguments were *not* found'
      lines = [ '', message, "#{unseen_args}", '' ]
      raise lines.join("\n")
    end
  end

end
