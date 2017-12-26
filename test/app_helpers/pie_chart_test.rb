require_relative 'app_helpers_test_base'
require_relative '../app_lib/delta_maker'

class PieChartTest < AppHelpersTestBase

  include PieChartHelper

  test '10E59F',
  'pie-chart from kata_increments() lights used in dashboard view' do
    kata = make_language_kata
    lion = kata.start_avatar(['lion'])

    maker = DeltaMaker.new(lion)
    runner.stub_run_colour('red')
    maker.run_test
    runner.stub_run_colour('green')
    maker.run_test

    lights = storer.kata_increments(kata.id)['lion']
    lights.shift

    size = 34
    expected = '' +
      '<canvas' +
      " class='pie'" +
      " data-red-count='1'" +
      " data-amber-count='0'" +
      " data-green-count='1'" +
      " data-timed-out-count='0'" +
      " data-key='lion'" +
      " width='#{size}'" +
      " height='#{size}'>" +
      '</canvas>'

    actual = pie_chart(lights, 'lion')

    assert_equal expected, actual
  end

end
