require_relative 'app_helpers_test_base'

class TipTest < AppHelpersTestBase

  def self.hex_prefix
    'BDA2B5'
  end

  include TrafficLightTipHelper

  test 'D52',
  'traffic light tip for individual kata' do
    in_kata do |kata|
      files = kata.files
      stdout = "Expected: 42\nActual: 54"
      stderr = 'assert failed'
      status = 4
      kata.ran_tests(1, files, time_now, stdout, stderr, status, 'red')

      filename = 'hiker.rb'
      hiker_rb = kata.files[filename]
      files[filename] = hiker_rb.sub('9','7')
      stdout = 'All tests passed'
      stderr = ''
      status = 0
      kata.ran_tests(2, files, time_now, stdout, stderr, status, 'green')

      # uses real differ-service
      events = kata.events
      diff = differ.diff(events[was_index=1].files, events[now_index=2].files)

      expected =
        '<table>' +
          '<tr>' +
            "<td><img src='/images/bulb_red.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
            "<td><span class='traffic-light-diff-tip-tag'>#{was_index}</span></td>" +
            "<td><div class='right-arrow'>&rarr;</div></td>" +
            "<td><img src='/images/bulb_green.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
            "<td><span class='traffic-light-diff-tip-tag'>#{now_index}</span></td>" +
          '</tr>' +
        '</table>' +
        '<table>' +
          '<tr>' +
            "<td><div class='traffic-light-diff-tip-line-count-deleted some button'>1</div></td>" +
            "<td><div class='traffic-light-diff-tip-line-count-added some button'>1</div></td>" +
            "<td>&nbsp;hiker.rb</td>" +
          '</tr>' +
        '</table>'

      actual = traffic_light_tip_html(diff, kata.events, was_index, now_index)
      assert_equal expected, actual
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test 'D53',
  'traffic light tip for kata in a group' do
    in_kata do |kata|
      files = kata.files
      stdout = "Expected: 42\nActual: 54"
      stderr = 'assert failed'
      status = 4
      kata.ran_tests(1, files, time_now, stdout, stderr, status, 'red')

      filename = 'hiker.rb'
      hiker_rb = kata.files[filename]
      files[filename] = hiker_rb.sub('9','7')
      stdout = 'All tests passed'
      stderr = ''
      status = 0
      kata.ran_tests(2, files, time_now, stdout, stderr, status, 'green')

      # uses real differ-service
      events = kata.events
      diff = differ.diff(events[was_index=1].files, events[now_index=2].files)

      expected =
        '<table>' +
          '<tr>' +
            "<td><img src='/images/bulb_red.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
            "<td><span class='traffic-light-diff-tip-tag'>#{was_index}</span></td>" +
            "<td><div class='right-arrow'>&rarr;</div></td>" +
            "<td><img src='/images/bulb_green.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
            "<td><span class='traffic-light-diff-tip-tag'>#{now_index}</span></td>" +
            "<td><img src='/images/avatars/wolf.jpg' class='traffic-light-diff-tip-avatar-image'></td>" +
          '</tr>' +
        '</table>' +
        '<table>' +
          '<tr>' +
            "<td><div class='traffic-light-diff-tip-line-count-deleted some button'>1</div></td>" +
            "<td><div class='traffic-light-diff-tip-line-count-added some button'>1</div></td>" +
            "<td>&nbsp;hiker.rb</td>" +
          '</tr>' +
        '</table>'

      actual = traffic_light_tip_html(diff, kata.events, was_index, now_index)
      assert_equal expected, actual
    end
  end
=end

end
