require_relative './app_helpers_test_base'

class TipTest < AppHelpersTestBase

  include TipHelper

  def setup_runner_class
    set_runner_class('StubRunner')
  end

  test 'BDAD52',
  'traffic light tip' do
    set_storer_class('FakeStorer')
    kata = make_kata({ 'language' => 'C (gcc)-assert' })
    lion = kata.start_avatar(['lion'])
    files = kata.visible_files
    now = [2016,12,22,5,55,11]
    output = "makefile:14: recipe for target 'test.output' failed"
    was_colour = :red
    lion.tested(files, now, output, was_colour)

    filename = 'hiker.c'
    hiker_c = kata.visible_files[filename]
    files[filename] = hiker_c.sub('9','7')
    output = 'All tests passed'
    now_colour = :green
    lion.tested(files, time_now, output, now_colour)

    diff = differ.diff(kata.id, lion.name, was_tag=1, now_tag=2)
    expected =
      "Click to review lion's<br/>" +
      "<span class='#{was_colour}'>#{was_tag}</span> " +
      "&harr; " +
      "<span class='#{now_colour}'>#{now_tag}</span> diff" +
      "<div>1 added line</div>" +
      "<div>1 deleted line</div>"
    actual = traffic_light_tip_html(diff, lion, was_tag, now_tag)
    assert_equal expected, actual
    runner.old_kata(kata.id)
  end

end
