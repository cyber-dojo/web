require_relative '../all'
require 'capybara/minitest'

# Base for browser (Capybara + Selenium) tests. These run inside the web
# container and drive Firefox in the selenium container, which loads the real
# web app at http://web:3000 over the compose network - so they exercise the
# rendered page and its JavaScript end to end, unlike the in-process Rack tests
# in app_controllers which never run browser JS.
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
    Capybara.app_host       = 'http://web:3000'
    Capybara.current_driver = :selenium
    Capybara.run_server     = false
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.app_host = nil
    super
  end

  # - - - - - - - - - - - - - - - - - - -

  def index_field_value
    evaluate_script(%q{document.querySelector("input[name='index']").value})
  end

  # The hidden index field is set by JavaScript (on load, and after each write),
  # so a read taken immediately after visit()/an action can race the handler.
  # Poll until it holds the expected value.
  def wait_for_index_field(expected)
    20.times do
      return if index_field_value == expected
      sleep 0.3
    end
    flunk "index field never became #{expected.inspect} (was #{index_field_value.inspect})"
  end

end
