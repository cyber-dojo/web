require_relative 'app_controller_test_base'

class RedAmberGreenTest  < AppControllerTestBase

  def self.hex_prefix
    'gh6'
  end

  test '223', %w( red-green-amber ) do
    set_runner_class('RunnerService')
    in_kata do |kata|
      post_run_tests
      assert_equal 'red', kata.event(-1)['colour']
      sub_file('hiker.sh', '6 * 9', '6 * 7')
      post_run_tests
      assert_equal 'green', kata.event(-1)['colour']
      change_file('hiker.sh', 'syntax-error')
      post_run_tests
      assert_equal 'amber', kata.event(-1)['colour']
    end
  end

end
