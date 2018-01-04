require_relative 'app_helpers_test_base'

class TipTest < AppHelpersTestBase

  def self.hex_prefix
    'BDA2B5'
  end

  include TipHelper

  test 'D52',
  'traffic light tip' do
    kata = make_language_kata({
      'display_name' => default_language_name('stateful')
    })
    lion = kata.start_avatar(['lion'])
    files = kata.visible_files
    now = [2016,12,22,5,55,11]
    output = "makefile:14: recipe for target 'test.output' failed"
    was_colour = :red
    lion.tested(files, now, output, was_colour) # 1

    filename = 'hiker.c'
    hiker_c = kata.visible_files[filename]
    files[filename] = hiker_c.sub('9','7')
    output = 'All tests passed'
    now_colour = :green
    lion.tested(files, time_now, output, now_colour) # 2

    # uses real differ-service
    diff = differ.diff(kata.id, 'lion', was_tag=1, now_tag=2)

    expected =
      '<table>' +
        '<tr>' +
          "<td><img src='/images/bulb_red.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
          "<td><span class='traffic-light-diff-tip-tag red'>1</span></td>" +
          "<td><div>&rarr;</div></td>" +
          "<td><img src='/images/bulb_green.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
          "<td><span class='traffic-light-diff-tip-tag green'>2</span></td>" +
          "<td><img src='/images/avatars/lion.jpg' class='traffic-light-diff-tip-avatar-image'></td>" +
        '</tr>' +
      '</table>' +
      '<table>' +
        '<tr>' +
          "<td><div class='traffic-light-diff-tip-line-count-deleted some button'>1</div></td>" +
          "<td><div class='traffic-light-diff-tip-line-count-added some button'>1</div></td>" +
          "<td>&nbsp;hiker.c</td>" +
        '</tr>' +
      '</table>'

    actual = traffic_light_tip_html(diff, lion, was_tag, now_tag)
    assert_equal expected, actual
    runner.kata_old(kata.image_name, kata.id)
  end

end
