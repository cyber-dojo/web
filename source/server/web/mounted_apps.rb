require_relative 'assets_app'
require_relative 'fork_app'
require_relative 'kata_app'
require_relative 'probes_app'
require_relative 'review_app'

module WebApp
  # The rack app to run: every app under its own mount point. config.ru and
  # the test base both call this, so the tests drive the topology production
  # serves rather than one app standing in for all of them.
  #
  # Rack::URLMap matches longest prefix first, so ProbesApp at '/' takes only
  # what no other mount claims, whatever order they are listed in here.
  def self.mounted(externals)
    Rack::URLMap.new(
      AssetsApp::MOUNT_PATH => AssetsApp.new(externals),
      ForkApp::MOUNT_PATH => ForkApp.new(externals),
      KataApp::MOUNT_PATH => KataApp.new(externals),
      ReviewApp::MOUNT_PATH => ReviewApp.new(externals),
      ProbesApp::MOUNT_PATH => ProbesApp.new(externals)
    )
  end
end
