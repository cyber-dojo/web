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
    files = kata.visible_files
    stdout,stderr,status = lion.test(delta, files)
    output = stdout+stderr
p "----1 stdout"
p stdout
p "----1 stderr"
p stderr
p "----1 status"
p status

    was_colour = kata.red_amber_green(output).to_s
    lion.tested(delta, files, time_now, output, was_colour)

    filename = 'hiker.c'
    hiker_c = kata.visible_files[filename]
    files[filename] = hiker_c.sub('9','7')
    delta[:changed] = [ filename ]
    stdout,stderr,status = lion.test(delta, files)
    output = stdout + stderr
p "----2 stdout"
p stdout
p "----2 stderr"
p stderr
p "----2 status"
p status

    now_colour = kata.red_amber_green(output).to_s
    lion.tested(delta, files, time_now, output, now_colour)

    diff = differ.diff(lion, was_tag=1, now_tag=2)
    expected =
      "Click to review lion's<br/>" +
      "<span class='red'>#{was_tag}</span> " +
      "&harr; " +
      "<span class='green'>#{now_tag}</span> diff" +
      "<div>1 added line</div>" +
      "<div>1 deleted line</div>"
    actual = traffic_light_tip_html(diff, lion, was_tag, now_tag)
    assert_equal expected, actual
    runner.old_kata(kata.id)
  end

end
