require_relative 'app_controller_test_base'

class RedAmberGreenTest  < AppControllerTestBase

  def self.hex_prefix
    'gh6'
  end

  test '223', %w( red-green-amber ) do
    with_runner_class('RunnerStub') do
      in_kata do |kata|
        runner.stub_run({outcome: 'red'})
        post_run_tests
        assert_equal 'red', kata.event(-1)['colour']

        runner.stub_run({outcome: 'green'})
        post_run_tests
        assert_equal 'green', kata.event(-1)['colour']

        runner.stub_run({outcome: 'amber'})
        post_run_tests
        assert_equal 'amber', kata.event(-1)['colour']
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '224', %w(
  |when run_tests() is 'red' and creates a file called outcome.special
  |then the colour becomes 'red_special
  ) do
    with_runner_class('RunnerService') do
      in_kata do |kata|
        @files['cyber-dojo.sh'] += "\necho Hi > outcome.special"
        post_run_tests
        assert_equal 'green_special', kata.event(-1)['colour']
      end
    end
  end

end
