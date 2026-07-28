require_relative 'browser_test_base'

# The kata-page traffic-light carries only major_index; its committed flat index
# (for review navigation and the diff tooltip) is resolved lazily on click/hover
# by reading the committed events and matching major_index (cd.lib.getEvents). A
# "ghost" - a light whose major_index is not among the committed events - gets a
# dead click and no tooltip. See docs/mobbing-stale-tab-lock.md (ADR A4/A5) and
# kata/_traffic_lights.erb + cyber-dojo_hover_tips.js.
class TrafficLightLazyIndexResolutionTest < BrowserTestBase

  FILE_EVENTS = %w( file_create file_delete file_rename file_edit )

  test 'LazyC1', %w(
  | clicking a kata-page traffic-light navigates review to the committed flat index
  | that the light's major_index resolves to over the read events - NOT to any index
  | carried on the light (it carries none).
  ) do
    id = saver.kata_create(starter_manifest)
    files = saver.kata_event(id, 0)['files']
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), laptop_id, next_tab_seq)
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('green'), laptop_id, next_tab_seq)

    lights = saver.kata_events(id).reject { |e| FILE_EVENTS.include?(e['colour']) }
    expected_index = lights.last['index']

    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    # Record where the click would navigate, instead of actually leaving the page.
    execute_script("cd.review.fromTestPage = (kataId, index) => { document.body.setAttribute('data-nav-index', index); };")
    all('#traffic-lights img.diff-traffic-light').last.click

    assert_selector "body[data-nav-index='#{expected_index}']", wait: 5
  end

  test 'LazyC2', %w(
  | clicking a ghost light (a major_index not among the committed events, eg a light
  | shown after a saver write that did not commit) does nothing - no navigation.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    execute_script("cd.review.fromTestPage = (kataId, index) => { document.body.setAttribute('data-nav-index', index); };")
    # Append a ghost: a major_index beyond any committed light. Trigger its click
    # handler via jQuery (LazyC1 covers a real click on a committed light); a
    # JS-appended ghost is not scrolled into view for a real Selenium click.
    execute_script("cd.kata.appendTrafficLight({colour: 'red', major_index: 999, minor_index: 0});")
    execute_script("jQuery('#traffic-lights img.diff-traffic-light').last().click()")

    sleep 0.5   # let the async getEvents resolve (it finds no match)
    refute_selector 'body[data-nav-index]', visible: :all
  end

  test 'LazyT1', %w(
  | hovering a kata-page traffic-light resolves its index lazily from major_index and
  | shows the diff-summary hover-tip.
  ) do
    id = saver.kata_create(starter_manifest)
    files = saver.kata_event(id, 0)['files']
    kata_ran_tests(id, files, content('out'), content('err'), 0, ran_summary('red'), laptop_id, next_tab_seq)

    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    execute_script("jQuery('#traffic-lights img.diff-traffic-light').last().mouseenter()")
    assert_selector '.hover-tip', wait: 5
  end

  test 'LazyT2', %w(
  | hovering a ghost light shows no hover-tip - its major_index matches no committed
  | event, so there is nothing to summarise.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready

    execute_script("cd.kata.appendTrafficLight({colour: 'red', major_index: 999, minor_index: 0});")
    execute_script("jQuery('#traffic-lights img.diff-traffic-light').last().mouseenter()")

    sleep 0.5   # let the async getEvents resolve (it finds no match)
    refute_selector '.hover-tip', visible: :all
  end

end
