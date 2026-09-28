require_relative 'browser_test_base'

class MountPathReachesJavascriptTest < BrowserTestBase

  # - - - - - - - - - - - - - - - - -

  qtest mp9k21: %w[
    |layout.erb hands the mount point to the JavaScript as cd.mountPath, which
    |is what every button builds its URL from. A page renders its title with
    |or without that working - the script would just throw - so assert the
    |value itself, in the browser, after the page has run its JavaScript.
  ] do
    visit(mounted_path('home'))
    assert_equal App::MOUNT_PATH, evaluate_script('cd.mountPath')
  end
end
