require_relative 'app'
require_relative 'fork_app'

module WebApp
  # The rack app to run: every app under its own mount point. config.ru and
  # the test base both call this, so the tests drive the topology production
  # serves rather than one app standing in for all of them.
  #
  # Rack::URLMap matches longest prefix first, so App at '/' takes only what
  # no other mount claims, whatever order they are listed in here.
  def self.mounted(externals)
    Rack::URLMap.new(
      ForkApp::MOUNT_PATH => ForkApp.new(externals),
      App::MOUNT_PATH => App.new(externals)
    )
  end
end
