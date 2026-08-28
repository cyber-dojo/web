require_relative '../after_response'
require_relative 'assets_app'
require_relative 'fork_app'
require_relative 'kata_app'
require_relative 'probes_app'
require_relative 'review_app'

module Web
  # The rack app to run: every app under its own mount point. config.ru and
  # the test base both call this, so the tests drive the topology production
  # serves rather than one app standing in for all of them.
  #
  # AfterResponse wraps the lot, so a route in any of them can stash work to run
  # once its response has been written.
  #
  # Rack::URLMap matches longest prefix first, so ProbesApp at '/' takes only
  # what no other mount claims, whatever order they are listed in here.
  def self.mounted(externals)
    AfterResponse.new(url_map(externals))
  end

  def self.url_map(externals)
    Rack::URLMap.new(
      AssetsApp::MOUNT_PATH => AssetsApp.new(externals),
      ForkApp::MOUNT_PATH => ForkApp.new(externals),
      KataApp::MOUNT_PATH => KataApp.new(externals),
      ReviewApp::MOUNT_PATH => ReviewApp.new(externals),
      ProbesApp::MOUNT_PATH => ProbesApp.new(externals)
    )
  end
end
