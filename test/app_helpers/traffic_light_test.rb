require_relative 'app_helpers_test_base'

class TrafficLightTest < AppHelpersTestBase

  def self.hex_prefix
    'CF694D'
  end

  include TrafficLightHelper

  test '67C',
  'traffic_light_count' do
    id = 'ABCDE12345'
    avatar_name = 'hippo'
    red_light   = { 'colour' => 'red'   }
    green_light = { 'colour' => 'green' }
    amber_light = { 'colour' => 'amber' }
    lights = [red_light, red_light, green_light, amber_light, amber_light]
    expected =
      "<div class='traffic-light-count amber'" +
          " data-tip='traffic_light_count'" +
          " data-id='#{id}'" +
          " data-avatar-name='#{avatar_name}'" +
          " data-current-colour='amber'" +
          " data-red-count='2'" +
          " data-amber-count='2'" +
          " data-green-count='1'" +
          " data-timed-out-count='0'>" +
        "5<" +
      "/div>"
    actual = traffic_light_count(id, avatar_name, lights)
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
    id = 'ABCDE12345'
    avatar_name = 'hippo'
    expected = '' +
      '<div' +
      " class='diff-traffic-light avatar-image'" +
      " data-tip='review #{avatar_name}&#39;s current code'" +
      " data-id='#{id}'" +
      " data-avatar-name='#{avatar_name}'" +
      " data-was-tag='-1'" +
      " data-now-tag='-1'>" +
      "<img src='/images/avatars/#{avatar_name}.jpg'" +
          " alt='#{avatar_name}'/>" +
      '</div>'
    actual = diff_avatar_image(id, avatar_name)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test '443',
  'diff_traffic_light' do
    diff_traffic_light_func('red')
    diff_traffic_light_func('amber')
    diff_traffic_light_func('green')
  end

  private

  def diff_traffic_light_func(colour)
    id = 'ABCDE12345'
    avatar_name = 'hippo'
    tag = 3
    expected = '' +
      '<div' +
      " class='diff-traffic-light'" +
      " data-tip='ajax:traffic_light'" +
      " data-id='#{id}'" +
      " data-avatar-name='#{avatar_name}'" +
      " data-colour='#{colour}'" +
      " data-was-tag='#{tag - 1}'" +
      " data-now-tag='#{tag}'>" +
      "<img src='/images/bulb_#{colour}.png'" +
          " alt='#{colour} traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(id, avatar_name, colour, tag)
    assert_equal expected, actual
  end

end
