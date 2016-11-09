#!/bin/bash ../test_wrapper.sh

require_relative './app_helpers_test_base'
require_relative './../app_lib/delta_maker'

class TipTest < AppHelpersTestBase

  include TipHelper

  def setup_runner_class
    set_runner_class('RunnerService')
  end

  test 'BDAD52',
  'traffic light tip' do
    kata = make_kata({ language: 'C (gcc)-assert' })
    lion = kata.start_avatar(['lion'])
    maker = DeltaMaker.new(lion)
    maker.run_test
    filename = 'hiker.c'
    assert maker.file?(filename)
    content = maker.content(filename)
    refute_nil content
    maker.change_file(filename, content.sub('9', '7'))
    maker.run_test
    diff = differ.diff(lion, was_tag=1, now_tag=2)

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
