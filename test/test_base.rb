require_relative 'test_domain_helpers'
require_relative 'test_external_helpers'
require_relative 'test_hex_id_helpers'
require 'minitest/autorun'
require 'etc'

# The executor that concurrent test classes share. Setting it parallelises
# nothing on its own: a class opts in with parallelize_me!, which the server
# test bases do. The browser base deliberately does not, because those tests
# drive one Capybara session.
Minitest.parallel_executor = Minitest::Parallel::Executor.new(Etc.nprocessors)

class TestBase < Minitest::Test

  # The apps live in the Web namespace. Including it here puts that module
  # in the ancestor chain of every test class, so tests name KataApp, Kata,
  # SaverService and friends unqualified.
  include Web

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

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
