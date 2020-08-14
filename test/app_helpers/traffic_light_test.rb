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
      event(0, colour:'red'  , predicted:'none'),
      event(1, colour:'red'  , predicted:'none'),
      event(2, colour:'amber', predicted:'none'),
      event(3, colour:'green', predicted:'none'),
      event(4, colour:'amber', predicted:'none'),
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

  test '443',
  'diff for traffic-light with no prediction and no revert' do
    id = 'a4r9YN'
    kata = OpenStruct.new(id:id)
    light = event(index=14, colour:'green', predicted:'none', kata:kata)
    number = 15
    avatar_index = 37
    expected = '' +
      "<div class='diff-traffic-light'" +
        " data-id='#{id}'" +
        " data-index='#{index}'" +
        " data-number='#{number}'" +
        " data-avatar-index='#{avatar_index}'" +
        " data-colour='green'>" +
        "<img src='/images/traffic-light/green.png'" +
           " alt='green traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(light, avatar_index, number)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test '444',
  'predicted correctly traffic-light' do
    id = 'Lr5ebj'
    kata = OpenStruct.new(id:id)
    light = event(index=14, colour:'green', predicted:'green', kata:kata)
    number = 15
    avatar_index = 37
    expected = '' +
      '<img class="tick" src="/images/traffic-light/circle-tick.png">' +
      "<div class='diff-traffic-light'" +
        " data-id='#{id}'" +
        " data-index='#{index}'" +
        " data-number='#{number}'" +
        " data-avatar-index='#{avatar_index}'" +
        " data-colour='green'>" +
        "<img src='/images/traffic-light/green.png'" +
           " alt='green traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(light, avatar_index, number)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test '445',
  'predicted incorrectly traffic-light' do
    id = 'Lr5ebj'
    kata = OpenStruct.new(id:id)
    light = event(index=14, colour:'red', predicted:'green', kata:kata)
    number = 16
    avatar_index = 38
    expected = '' +
      '<img class="cross" src="/images/traffic-light/circle-cross.png">' +
      "<div class='diff-traffic-light'" +
        " data-id='#{id}'" +
        " data-index='#{index}'" +
        " data-number='#{number}'" +
        " data-avatar-index='#{avatar_index}'" +
        " data-colour='red'>" +
        "<img src='/images/traffic-light/red.png'" +
           " alt='red traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(light, avatar_index, number)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - -

  test '446',
  'reverted traffic-light' do
    id = 'Lr5ebj'
    kata = OpenStruct.new(id:id)
    light = event(index=14, colour:'red', kata:kata, revert:[id,6])
    number = 19
    avatar_index = 41
    expected = '' +
      '<img class="revert" src="/images/traffic-light/circle-revert.png">' +
      "<div class='diff-traffic-light'" +
        " data-id='#{id}'" +
        " data-index='#{index}'" +
        " data-number='#{number}'" +
        " data-avatar-index='#{avatar_index}'" +
        " data-colour='red'>" +
        "<img src='/images/traffic-light/red.png'" +
           " alt='red traffic-light'/>" +
      '</div>'
    actual = diff_traffic_light(light, avatar_index, number)
    assert_equal expected, actual
  end

  private

  def event(index, args)
    summary = {
      'index' => index,
      'colour' => args[:colour],
      'predicted' => (args[:predicted] || 'none')
    }
    if args[:revert]
      summary['revert'] = args[:revert]
    end
    Event.new(args[:kata], summary)
  end

end
