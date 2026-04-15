require_relative 'app_controller_test_base'

class PredictedTest  < AppControllerTestBase

  test '1D35b7', %w(
  | predicted right, no auto-revert when wrong 
  ) do
    in_kata do |kata|
      runner.stub_run({outcome: 'red'})
      post_run_tests({predicted: 'red'})
      last = kata.event(-1)
      assert_equal 'red', last['predicted']
      assert_equal 'red', last['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '1D35b8', %w(
  | predicted wrong, no auto-revert when wrong 
  ) do
    in_kata do |kata|
      runner.stub_run({outcome: 'amber'})
      post_run_tests({predicted: 'red'})
      last = kata.event(-1)
      assert_equal 'red', last['predicted']
      assert_equal 'amber', last['colour']
    end
  end

end
