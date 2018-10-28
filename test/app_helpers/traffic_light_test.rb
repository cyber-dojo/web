require_relative 'app_helpers_test_base'

class TrafficLightTest < AppHelpersTestBase

  def self.hex_prefix
    'CF694D'
  end

  include TrafficLightHelper

  class KataStub
    def id
      '456eGz'
    end
    def avatar_name
      'lion'
    end
  end

  #- - - - - - - - - - - - - - - -

  test '67C',
  'traffic_light_count' do
    stub = KataStub.new
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
          " data-avatar-name='lion'" +
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
    id = 'ABCDz1'
    avatar_name = 'hippo'
    expected = '' +
      '<div' +
      " class='avatar-image'" +
      " data-tip='review #{avatar_name}&#39;s<br/>current code'" +
      " data-id='#{id}'>" +
      "<img src='/images/avatars/#{avatar_name}.jpg'" +
          " alt='#{avatar_name}'/>" +
      '</div>'
    actual = diff_avatar_image(id, avatar_name)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test '443',
  'diff_traffic_light' do
    stub = KataStub.new
    red = Event.new(nil, stub, { 'colour' => 'red'     }, 14)
    expected = '' +
      "<div class='diff-traffic-light'" +
        " data-tip='ajax:traffic_light'" +
        " data-id='#{stub.id}'" +
        " data-colour='red'" + # [1]
        " data-tag='14'>" +
        "<img src='/images/bulb_red.png'" +
           " alt='red traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(red)
    assert_equal expected, actual

  end

end
