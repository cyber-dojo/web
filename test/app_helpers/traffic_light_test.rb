require_relative 'app_helpers_test_base'
require 'ostruct'

class TrafficLightTest < AppHelpersTestBase

  def self.hex_prefix
    'Hf6'
  end

  include TrafficLightHelper

  #- - - - - - - - - - - - - - - -

  test '67C',
  'traffic_light_count' do
    lights = [
      event(0, 'red'),
      event(1, 'red'),
      event(2, 'amber'),
      event(3, 'green'),
      event(4, 'amber'),
    ]
    expected =
      "<div class='traffic-light-count-wrapper'>" +
        "<div class='traffic-light-count amber'" +
            " data-tip='traffic_light_count'" +
            " data-red-count='2'" +
            " data-amber-count='2'" +
            " data-green-count='1'" +
            " data-timed-out-count='0'>" +
          "5" +
        "</div>" +
      "</div>"
    actual = traffic_light_count(lights)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test 'E41',
  'traffic_light_image' do
    colour = 'red'
    expected = "<img src='/traffic-light/image/#{colour}.png'" +
               " alt='red traffic-light'/>"
    actual = traffic_light_image(colour)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test '443',
  'diff_traffic_light' do
    kata = OpenStruct.new(id: 'a4r9YN')
    red = event(14, 'red', kata)
    expected = '' +
      "<div class='diff-traffic-light'" +
        " data-id='a4r9YN'" +
        " data-index='14'" +
        " data-colour='red'>" +
        "<img src='/traffic-light/image/red.png'" +
           " alt='red traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(red)
    assert_equal expected, actual
  end

  private

  def event(index, colour, kata=nil)
    Event.new(kata, { 'index' => index, 'colour' => colour })
  end

end
