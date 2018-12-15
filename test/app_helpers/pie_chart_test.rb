require_relative 'app_helpers_test_base'

class PieChartTest < AppHelpersTestBase

  def self.hex_prefix
    '1PE'
  end

  include PieChartHelper

  class KataStub
    def avatar_name
      'wolf'
    end
  end

  test '060',
  'pie-chart from lights' do
    stub = KataStub.new
    lights = [
      Event.new(nil, stub, { 'colour' => 'red'   }, 0),
      Event.new(nil, stub, { 'colour' => 'green' }, 1),
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
      " data-key='wolf'" +
      " width='#{size}px'" +
      " height='#{size}px'>" +
      '</canvas>' +
      '</div>'

    actual = pie_chart(lights)

    assert_equal expected, actual
  end

end
