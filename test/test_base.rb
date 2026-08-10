# The production code this file's 'include Web' needs. Requiring it here, and
# not leaving it to whichever file happens to be loaded first, is what lets a
# test file require only test_base. test/run.sh shuffles the load order.
require_relative 'all'
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

  # Raises unless every tid argument the run was filtered by matched at least
  # one test-ID, so a mistyped 'make test_server tids=...' is reported instead
  # of quietly running nothing. Takes both as arguments so a test can drive it
  # without disturbing the globals the run itself uses.
  def self.check_all_tid_args_matched(args, seen_ids)
    unseen_args = args.find_all { |arg|
      seen_ids.none? { |id|
        id.include?(arg)
      }
    }
    unless unseen_args == []
      message = 'the following test id arguments were *not* found'
      lines = [ '', message, "#{unseen_args}", '' ]
      raise lines.join("\n")
    end
  end

  Minitest.after_run do
    check_all_tid_args_matched($args, $seen_ids)
  end

end
