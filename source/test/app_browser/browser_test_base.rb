require_relative '../all'
require 'capybara/minitest'

# Base for browser (Capybara + Selenium) tests. These run inside the web
# container and drive Firefox in the selenium container, which loads the real
# web app through nginx (http://nginx) over the compose network - so they
# exercise the rendered page and its JavaScript end to end, including
# browser-side reads of /saver/... which nginx proxies to saver (web has no
# /saver route). Unlike the in-process Rack tests in app_controllers, these run
# browser JS.
class BrowserTestBase < TestBase

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

end
