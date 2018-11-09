require_relative 'app_helpers_test_base'

class TrafficLightTest < AppHelpersTestBase

  def self.hex_prefix
    'Hf6'
  end

  include TrafficLightHelper

  class KataStub
    def initialize(id, avatar_name)
      @id = id
      @avatar_name = avatar_name
    end
    attr_reader :id, :avatar_name
  end

  #- - - - - - - - - - - - - - - -

  test '67C',
  'traffic_light_count' do
    stub = KataStub.new(nil, 'fox')
    lights = [
      Event.new(nil, stub, { 'colour' => 'red'     }, 0),
      Event.new(nil, stub, { 'colour' => 'red'     }, 1),
      Event.new(nil, stub, { 'colour' => 'amber'   }, 2),
      Event.new(nil, stub, { 'colour' => 'green'   }, 3),
      Event.new(nil, stub, { 'colour' => 'amber'   }, 4),
    ]
    expected =
      "<div class='traffic-light-count amber'" +
          " data-tip='traffic_light_count'" +
          " data-red-count='2'" +
          " data-amber-count='2'" +
          " data-green-count='1'" +
          " data-timed-out-count='0'>" +
        "5" +
      "</div>"
    actual = traffic_light_count(lights)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test 'E41',
  'traffic_light_image' do
    colour = 'red'
    expected = "<img src='/images/bulb_#{colour}.png'" +
               " alt='red traffic-light'/>"
    actual = traffic_light_image(colour)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test '647',
  'diff_avatar_image' do
    stub = KataStub.new('456eGz', 'snake')
    lights = [
      Event.new(nil, stub, { 'colour' => 'red' }, 0),
    ]
    expected = '' +
      '<div' +
      " class='avatar-image'" +
      " data-tip='review snake&#39;s<br/>current code'" +
      " data-id='456eGz'>" +
      "<img src='/images/avatars/snake.jpg'" +
          " alt='snake'/>" +
      '</div>'
    actual = diff_avatar_image(lights)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test '443',
  'diff_traffic_light' do
    stub = KataStub.new('a4r9YN', nil)
    red = Event.new(nil, stub, { 'colour' => 'red'     }, 14)
    expected = '' +
      "<div class='diff-traffic-light'" +
        " data-id='a4r9YN'" +
        " data-index='14'" +
        " data-colour='red'>" + # [1]
        "<img src='/images/bulb_red.png'" +
           " alt='red traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(red)
    assert_equal expected, actual

  end

end
