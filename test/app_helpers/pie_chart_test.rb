require_relative 'app_helpers_test_base'
require_relative '../app_lib/delta_maker'

class PieChartTest < AppHelpersTestBase

  def self.hex_prefix
    '10E59F'
  end

  include PieChartHelper

  test '060',
  'pie-chart from kata_increments() lights used in dashboard view' do
    in_kata {
      as(:wolf) {
        maker = DeltaMaker.new(wolf)
        runner.stub_run_colour('red')
        maker.run_test
        runner.stub_run_colour('green')
        maker.run_test
        lights = storer.kata_increments(kata.id)['wolf']
        lights.shift
        size = 34
        expected = '' +
          '<canvas' +
          " class='pie'" +
          " data-red-count='1'" +
          " data-amber-count='0'" +
          " data-green-count='1'" +
          " data-timed-out-count='0'" +
          " data-key='wolf'" +
          " width='#{size}'" +
          " height='#{size}'>" +
          '</canvas>'

        actual = pie_chart(lights, 'wolf')

        assert_equal expected, actual
      }
    }
  end

end
