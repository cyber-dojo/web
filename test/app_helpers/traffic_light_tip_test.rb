require_relative 'app_helpers_test_base'

class TipTest < AppHelpersTestBase

  def self.hex_prefix
    'Qd4'
  end

  include TrafficLightTipHelper

  test 'D52',
  'traffic light tip for individual kata does not have avatar-image' do
    in_kata do |kata|
      files = kata.files
      stdout = file("Expected: 42\nActual: 54")
      stderr = file('assert failed')
      status = 4
      kata.ran_tests(1, files, time_now, duration, stdout, stderr, status, 'red')

      filename = 'hiker.rb'
      hiker_rb = kata.files[filename]['content']
      files[filename] = file(hiker_rb.sub('9','7'))
      stdout = file('All tests passed')
      stderr = file('')
      status = 0
      kata.ran_tests(2, files, time_now, duration, stdout, stderr, status, 'green')

      events = kata.events
      was_files = files_for(events, was_index=1)
      now_files = files_for(events, now_index=2)
      diff = differ.diff(was_files, now_files)

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

      actual = traffic_light_tip_html(diff, events, was_index, now_index)
      assert_equal expected, actual
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D53',
  'traffic light tip for kata in a group does have an avatar-image' do
    in_group do |group|
      kata = group.join
      files = kata.files
      stdout = file("Expected: 42\nActual: 54")
      stderr = file('assert failed')
      status = 4
      kata.ran_tests(1, files, time_now, duration, stdout, stderr, status, 'red')

      filename = 'hiker.rb'
      hiker_rb = kata.files[filename]['content']
      files[filename] = file(hiker_rb.sub('9','7'))
      stdout = file('All tests passed')
      stderr = file('')
      status = 0
      kata.ran_tests(2, files, time_now, duration, stdout, stderr, status, 'green')

      events = kata.events
      was_files = files_for(events, was_index=1)
      now_files = files_for(events, now_index=2)
      diff = differ.diff(was_files, now_files)

      expected =
        '<table>' +
          '<tr>' +
            "<td><img src='/images/bulb_red.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
            "<td><span class='traffic-light-diff-tip-tag'>#{was_index}</span></td>" +
            "<td><div class='right-arrow'>&rarr;</div></td>" +
            "<td><img src='/images/bulb_green.png' class='traffic-light-diff-tip-traffic-light-image'></td>" +
            "<td><span class='traffic-light-diff-tip-tag'>#{now_index}</span></td>" +
            "<td><img src='/images/avatars/#{kata.avatar_name}.jpg' class='traffic-light-diff-tip-avatar-image'></td>" +
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

  private

  def files_for(events, index)
    Hash[events[index].files(:with_output).map{ |filename,file|
      [filename, file['content']]
    }]
  end

  def file(content)
    { 'content' => content,
      'truncated' => false
    }
  end

end
