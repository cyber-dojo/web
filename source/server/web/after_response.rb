# frozen_string_literal: true

require 'rack'

module Web
  # Middleware running work a route has stashed, after the response body has
  # been written. A route stashes work it does not want the browser to wait for;
  # Rack::BodyProxy runs it when the server closes the body, which is after the
  # bytes have gone out. The work stays inside the request, so it holds no
  # thread of its own and the server drains it at shutdown.
  #
  # This wraps the body the app returns, so it sees a response Sinatra has
  # already finished: content-length is set from the route's own body, not lost
  # to the wrapper.
  class AfterResponse
    # Where the stashed work travels from the route to this middleware. Named
    # here only, so a route stashes through stash() rather than spelling it.
    def self.env_key
      'cyber_dojo.after_response'
    end

    # Stashes work for this request, to run once the response has been written.
    def self.stash(env, work)
      env[env_key] = work
    end

    # Reads back what stash() put in the env, or nil when a route stashed
    # nothing. Only this middleware calls it.
    def self.stashed(env)
      env[env_key]
    end

    def initialize(app)
      @app = app
    end

    # Passes the request down and wraps the body, so closing it runs the work.
    def call(env)
      status, headers, body = @app.call(env)
      work = self.class.stashed(env)
      if work.nil?
        [status, headers, body]
      else
        [status, headers, Rack::BodyProxy.new(body) { work.call }]
      end
    end
  end
end
