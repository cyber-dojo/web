require_relative '../test_base'
require 'capybara/minitest'

# Base for browser (Capybara + Selenium) tests. These run inside the web
# container and drive Firefox in the selenium container, which loads the real
# web app through nginx (http://nginx) over the compose network - so they
# exercise the rendered page and its JavaScript end to end, including
# browser-side reads of /saver/... which nginx proxies to saver (web has no
# /saver route). Unlike the in-process Rack tests in server/apps, these run
# browser JS.
class ClientTestBase < TestBase

  include Capybara::DSL
  include Capybara::Minitest::Assertions

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
                                   browser: :remote,
                                   url: 'http://selenium:4444/wd/hub',
                                   capabilities: :firefox)
  end

  def setup
    super
    Capybara.app_host       = 'http://nginx'
    Capybara.current_driver = :selenium
    Capybara.run_server     = false
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.app_host = nil
    super
  end

  # - - - - - - - - - - - - - - - - - - -

  # The edit page's load-time JavaScript seeds cd.mobbingPoll.knownHead (from the
  # committed events) as one of its last init steps; it is undefined until then.
  # A read/action taken immediately after visit() can race that init, so poll
  # until knownHead is a number, ie the page is fully initialised.
  def wait_for_edit_page_ready
    20.times do
      return if evaluate_script(%q{typeof cd.mobbingPoll.knownHead === 'number'})
      sleep 0.3
    end
    flunk 'edit page never finished initialising (cd.mobbingPoll.knownHead stayed undefined)'
  end

  # A kata whose hiker.sh is edited (event 1) and then tested (event 2), so
  # review has a changed file to select and an output to show.
  def kata_with_one_test_run
    id = saver.kata_create(starter_manifest)
    files = saver.kata_event(id, 0)['files']
    files['hiker.sh']['content'] = files['hiker.sh']['content'].sub('6 * 9', '6 * 7')
    kata_ran_tests(id, files, content('out'), content('err'), 0,
                   ran_summary('red'), laptop_id, next_tab_seq)
    id
  end

  # Slides the ... panel out; its rows are hidden until it has.
  def open_more_panel
    find('#more-button').click
    assert_selector('body.more-open', wait: 5)
  end

  # Slides the ... panel back, so the page under it can be clicked again.
  def close_more_panel
    find('#more-button').click
    refute_selector('body.more-open', wait: 5)
    refute_selector('#help-button', visible: true, wait: 5)
  end

end
