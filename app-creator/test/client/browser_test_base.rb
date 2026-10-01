require_relative '../server/creator_test_base'
require 'capybara/minitest'

# Base for the browser (Capybara + Selenium) tests. These run inside the
# creator container and drive Firefox in the selenium container, which loads
# the app through the real nginx (http://nginx) over the compose network - the
# same nginx image production runs, with its rate limits turned up for the test
# run. Unlike the in-process Rack tests in test/server, these render the page
# and run its JavaScript.
class BrowserTestBase < CreatorTestBase

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

  def any_exercises_start_points_display_name
    exercises_start_points.names.sample
  end

end
