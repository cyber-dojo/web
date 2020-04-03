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
      event(0, 'red'  , 'none'),
      event(1, 'red'  , 'none'),
      event(2, 'amber', 'none'),
      event(3, 'green', 'none'),
      event(4, 'amber', 'none'),
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

  test 'E41', %w(
  traffic_light_image has
  prediction for red|amber|green
  but not for faulty|timed_out
  ) do
    red = event(0, colour='red')
    expected_red = "<img src='/traffic-light/image/red_predicted_none.png'" +
                   " alt='red traffic-light'/>"
    assert_equal expected_red, traffic_light_image(red)

    amber = event(1, colour='amber')
    expected_amber = "<img src='/traffic-light/image/amber_predicted_none.png'" +
                     " alt='amber traffic-light'/>"
    assert_equal expected_amber, traffic_light_image(amber)

    green = event(2, colour='green')
    expected_green = "<img src='/traffic-light/image/green_predicted_none.png'" +
                     " alt='green traffic-light'/>"
    assert_equal expected_green, traffic_light_image(green)

    faulty = event(3, colour='faulty')
    expected_faulty = "<img src='/traffic-light/image/faulty.png'" +
                      " alt='faulty traffic-light'/>"
    assert_equal expected_faulty, traffic_light_image(faulty)

    timed_out = event(4, colour='timed_out')
    expected_timed_out = "<img src='/traffic-light/image/timed_out.png'" +
                         " alt='timed_out traffic-light'/>"
    assert_equal expected_timed_out, traffic_light_image(timed_out)
  end

  #- - - - - - - - - - - - - - - -

  test '443',
  'diff_traffic_light' do
    id = 'a4r9YN'
    kata = OpenStruct.new(id:id)
    light = event(index=14, colour='green', predicted='none', kata)
    avatar_index = 37
    expected = '' +
      "<div class='diff-traffic-light'" +
        " data-id='#{id}'" +
        " data-index='#{index}'" +
        " data-avatar-index='#{avatar_index}'" +
        " data-colour='#{colour}'>" +
        "<img src='/traffic-light/image/green_predicted_none.png'" +
           " alt='green traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(light, avatar_index)
    assert_equal expected, actual
  end

  private

  def event(index, colour, predicted='none', kata=nil)
    Event.new(kata, {
      'index' => index,
      'colour' => colour,
      'predicted' => predicted,
    })
  end

end
