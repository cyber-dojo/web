require_relative 'app_helpers_test_base'

class PieChartTest < AppHelpersTestBase

  def self.hex_prefix
    '1PE'
  end

  include PieChartHelper

  test '060',
  'pie-chart from lights' do
    kata_id = 'eMjjWQ'
    lights = [
      Event.new(nil, { 'colour' => 'red',   'index' => 0}),
      Event.new(nil, { 'colour' => 'green', 'index' => 1}),
    ]
    size = 32
    expected = '' +
    '<div ' +
      " class='pie-chart-wrapper'" +
      " width='#{size}px'" +
      " height='#{size}px'>" +
      '<canvas' +
      " class='pie'" +
      " data-red-count='1'" +
      " data-amber-count='0'" +
      " data-green-count='1'" +
      " data-timed-out-count='0'" +
      " data-key='#{kata_id}'" +
      " width='#{size}px'" +
      " height='#{size}px'>" +
      '</canvas>' +
      '</div>'

    actual = pie_chart(kata_id, lights)

    assert_equal expected, actual
  end

end
