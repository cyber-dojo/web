require_relative 'app_helpers_test_base'

class TipTest < AppHelpersTestBase

  def self.hex_prefix
    'BDA2B5'
  end

  include TrafficLightTipHelper

  test 'D52',
  'traffic light tip' do
    in_kata {
      as(:wolf) {
        files = kata.visible_files
        now = [2016,12,22, 5,55,11]
        stdout = "Expected: 42\nActual: 54"
        stderr = 'assert failed'
        was_colour = :red
        wolf.tested(files, now, stdout, stderr, was_colour) # 1

        filename = 'hiker.rb'
        hiker_rb = kata.visible_files[filename]
        files[filename] = hiker_rb.sub('9','7')
        stdout = 'All tests passed'
        stderr = ''
        now_colour = :green
        wolf.tested(files, time_now, stdout, stderr, now_colour) # 2

        # uses real differ-service
        diff = differ.diff(kata.id, 'wolf', was_tag=1, now_tag=2)

        expected =
          '<table>' +
            '<tr>' +
              "<td><img src='/images/bulb_red.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
              "<td><span class='traffic-light-diff-tip-tag'>1</span></td>" +
              "<td><div class='right-arrow'>&rarr;</div></td>" +
              "<td><img src='/images/bulb_green.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
              "<td><span class='traffic-light-diff-tip-tag'>2</span></td>" +
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

        actual = traffic_light_tip_html(diff, wolf, was_tag, now_tag)
        assert_equal expected, actual
      }
    }
  end

end
