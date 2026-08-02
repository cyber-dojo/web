require_relative 'app_controller_test_base'

class TimedOutTest  < AppControllerTestBase

  test 'jB4221', %w(
  | timed_out 
  ) do
    in_kata do |kata|
      runner.stub_run({outcome: 'timed_out'})
      post_run_tests
      assert_equal 'timed_out', kata.event(-1)['colour']
    end
  end

end
