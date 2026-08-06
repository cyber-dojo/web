require_relative 'app_base'

module Web
  # Forking a practice from a traffic-light. Two routes that differ in one
  # word, which is why the prefix holds the word they share.
  class ForkApp < AppBase

    # Where this app mounts itself. Named here so config.ru and the tests
    # mount it identically. Rack strips it, so the routes below are the rest
    # of the path: /fork/kata arrives here as /kata.
    MOUNT_PATH = '/fork'.freeze

    post '/kata' do
      content_type :json
      { 'kata_fork' => saver.kata_fork(id, index) }.to_json
    end

    post '/group' do
      content_type :json
      { 'group_fork' => saver.group_fork(id, index) }.to_json
    end

  end
end
