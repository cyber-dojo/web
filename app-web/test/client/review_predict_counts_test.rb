require_relative 'client_test_base'

# Review shows its predict counts whenever predict is on, as the kata page
# does, not only once a light has been predicted.
class ReviewPredictCountsTest < ClientTestBase

  test 'Pc6tX1', %w(
  | with predict on, review shows the predict counts though no light has
  | been predicted yet
  ) do
    id = kata_with_one_test_run
    saver.kata_option_set(id, 'predict', 'on')
    visit "/review/show/#{id}?now_index=2&diff=simple"
    assert_selector('#review-page .tab.filename.selected', wait: 5)
    assert_equal 'on', evaluate_script('cd.settings.predict()'), 'the kata has predict on'
    assert_selector('.review.predict-counts', visible: true, wait: 5)
  end

  test 'Pc6tX2', %w(
  | with predict off and no light predicted, review shows no predict counts
  ) do
    id = kata_with_one_test_run
    saver.kata_option_set(id, 'predict', 'off')
    visit "/review/show/#{id}?now_index=2&diff=simple"
    assert_selector('#review-page .tab.filename.selected', wait: 5)
    assert_equal 'off', evaluate_script('cd.settings.predict()'), 'the kata has predict off'
    refute_selector('.review.predict-counts', visible: true)
  end
end
