require 'English'
require 'sinatra/base'
require_relative 'http_json_hash/service'
require_relative 'json_hash_parse_helper'
require 'json'
require 'digest'

module CreatorApp
  class AppBase < Sinatra::Base
    # Compiled assets live in ${APP_DIR}/assets, a sibling of source/,
    # populated by the Dockerfile from the asset_builder stage, which keeps the
    # precompiled app.css/app.js out of the repo tree.
    ASSETS_DIR = "#{ENV.fetch('APP_DIR')}/assets".freeze

    # Returns the public URL path for a compiled asset, fingerprinted with a
    # short hash of its content, eg "/assets/app-1a2b3c4d.css". Embedding the
    # hash in the path gives each version a unique URL, so it can be cached
    # immutably for a year; browsers then serve it from cache instead of
    # re-pulling it on every page navigation through nginx's rate-limited
    # /creator/ zone (which previously tripped a 429).
    def self.asset_path(filename)
      src  = "#{ASSETS_DIR}/#{filename}"
      hash = Digest::SHA256.file(src).hexdigest[0, 8]
      base = File.basename(filename, '.*')
      ext  = File.extname(filename)
      "/assets/#{base}-#{hash}#{ext}"
    end

    CSS_PATH = asset_path('app.css')
    JS_PATH  = asset_path('app.js')

    # A path from the host root: wherever the app is mounted, plus this path.
    # Sinatra's to() returns a full URL unless told otherwise, and a full URL
    # would bake in the host the request happened to arrive on.
    def path_to(path)
      to(path, false)
    end

    # The stylesheet's URL as the browser requests it; error_layout.erb links
    # it by this name, which every app defines.
    def css_url
      path_to(CSS_PATH)
    end

    # Wires the app to its collaborators (saver, runner, start-points, differ).
    def initialize(externals)
      @externals = externals
      super(nil)
    end

    set :port, ENV['PORT']

    # Send redirects as a path, not a full URL. nginx fronts this app and
    # terminates TLS, so the scheme and host Sinatra sees are its own (http, the
    # container) not the ones the browser used; a path Location leaves the
    # browser to keep its own scheme and host.
    set :absolute_redirects, false

    # Permit all Host headers; nginx fronts this app and validates Host.
    # Without this, Sinatra's development-mode host authorization rejects any
    # Host that is not localhost/.test (eg Rack::Test's example.org) with
    # 'Host not permitted'.
    set :host_authorization, {}

    # - - - - - - - - - - - - - - - -
    # Assets

    get CSS_PATH do
      cache_control :public, max_age: 31_536_000, immutable: true
      content_type 'text/css'
      send_file "#{ASSETS_DIR}/app.css"
    end

    get JS_PATH do
      cache_control :public, max_age: 31_536_000, immutable: true
      content_type 'text/javascript'
      send_file "#{ASSETS_DIR}/app.js"
    end

    def self.get_delegate(klass, name)
      get "/#{name}" do
        content_type :json
        target = klass.new(@externals)
        result = target.public_send(name, params)
        { name => result }.to_json
      end
    end

    private_class_method :get_delegate

    private

    def json_args
      @json_args ||= symbolized(json_payload)
    end

    def symbolized(hash)
      # named-args require symbolization
      hash.transform_keys(&:to_sym)
    end

    def json_payload
      request.body.rewind # Already been read in sinatra 4.0.0 !
      json_hash_parse(request.body.read)
    end

    include JsonHashParseHelper

    # Errors reach the error hook below in every environment, tests included,
    # rather than depending on which RACK_ENV Sinatra derives its defaults from.
    set :show_exceptions, false
    set :raise_errors, false

    # Every app answers an unmatched path the same way, because rack sends
    # each unmatched path to whichever app owns its prefix: /creator/nonsense
    # never reaches another app. A hook rather than a get '*' route, so it
    # covers every verb and cannot shadow a route declared after it.
    not_found do
      status 404
      erb :error, layout: :error_layout
    end

    error do
      error = $ERROR_INFO
      info = {
        exception: {
          request: {
            path: request.path,
            body: request.body&.read
          },
          backtrace: error.backtrace
        }
      }
      exception = info[:exception]
      if error.instance_of?(HttpJsonHash::ServiceError)
        exception[:http_service] = error.to_h
        # Preserve a client error (4xx) from the downstream service instead of
        # flattening it to 500; anything else stays a server error.
        code = error.status.to_i
        status(code) if (400..499).cover?(code)
      else
        exception[:message] = error.message
      end
      puts JSON.pretty_generate(info)
      halt erb :error, layout: :error_layout
    end
  end
end
