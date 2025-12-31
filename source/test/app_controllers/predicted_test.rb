require_relative 'app_controller_test_base'

class PredictedTest  < AppControllerTestBase

  def self.hex_prefix
    '1D3'
  end

  test '5b7', %w( predicted right, no auto-revert when wrong ) do
    in_kata do |kata|
      runner.stub_run({outcome: 'red'})
      post_run_tests({predicted: 'red'})
      last = kata.event(-1)
      assert_equal 'red', last['predicted']
      assert_equal 'red', last['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '5b8', %w( predicted wrong, no auto-revert when wrong ) do
    in_kata do |kata|
      runner.stub_run({outcome: 'amber'})
      post_run_tests({predicted: 'red'})
      last = kata.event(-1)
      assert_equal 'red', last['predicted']
      assert_equal 'amber', last['colour']
    end
  end

end
