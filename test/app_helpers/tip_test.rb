#!/bin/bash ../test_wrapper.sh

require_relative './app_helpers_test_base'

class TipTest < AppHelpersTestBase

  include TipHelper

  def setup_runner_class
    set_runner_class('RunnerService')
  end

  test 'BDAD52',
  'traffic light tip' do
    kata = make_kata({ language: 'C (gcc)-assert' })
    lion = kata.start_avatar(['lion'])
    delta = {
      :deleted => [],
      :new => {},
      :changed => {}
    }
    lion.test(delta, files={})

    filename = 'hiker.c'
    hiker_c = visible_files[filename]
    files[filename] = hiker_c.sub('9','7')
    delta[:changed] = [ filename ]
    lion.test(delta, files)

    was_tag_colour = 'red'
    now_tag_colour = 'green'
    expected =
      "Click to review lion's<br/>" +
      "<span class='#{was_tag_colour}'>#{was_tag}</span> " +
      "&harr; " +
      "<span class='#{now_tag_colour}'>#{now_tag}</span> diff" +
      "<div>1 added line</div>" +
      "<div>1 deleted line</div>"
    actual = traffic_light_tip_html(diff, lion, was_tag, now_tag)
    assert_equal expected, actual
    runner.old_kata(kata.id)
  end

end
