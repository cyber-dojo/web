require_relative 'app_controller_test_base'

class TimedOutTest  < AppControllerTestBase

  def self.hex_prefix
    'jB4'
  end

  test '221', %w( timed_out ) do
    with_runner_class('RunnerService') do
      in_kata do |kata|
        change_file('hiker.sh',
          <<~BASH_CODE
          answer()
          {
            while true; do
              :
            done
          }
          BASH_CODE
        )
        post_run_tests({ 'max_seconds' => 3 })
        assert_equal 'timed_out', kata.event(-1)['colour']
      end
    end
  end

end
