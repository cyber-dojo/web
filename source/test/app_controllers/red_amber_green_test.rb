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
  |and the outcome.special file is not saved
  ) do
    with_runner_class('RunnerStub') do
      in_kata do |kata|
        runner.stub_run({
          outcome: 'red',
          created: {'outcome.special' => content('Hello')}
        })
        post_run_tests 
        last = kata.event(-1)
        assert_equal 'red_special', last['colour']
        refute last['files'].keys.include?('outcome.special')
      end
    end
  end

end
