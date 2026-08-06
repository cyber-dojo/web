require 'sinatra/base'
require 'digest'
require 'json'
require 'rack/protection'
require_relative 'externals'

module WebApp
  # What every mounted app needs: its collaborators, the csrf and laptop-id
  # cookies, the compiled-asset paths, the request-param readers and the 500
  # handler. Routes live in the subclasses, because Sinatra hands a subclass
  # every route its superclass defines - which is exactly why one app cannot
  # simply descend from another.
  class AppBase < Sinatra::Base

    set :views, "#{__dir__}/views"
    set :public_folder, "#{__dir__}/public"
    set :host_authorization, {}
    set :protection, except: [:http_origin, :json_csrf]
    enable :static

    def initialize(externals)
      super()
      @externals = externals
      # Sinatra's render() reads @default_layout, which Sinatra::Base#initialize
      # sets to :layout. Naming it here is what wraps every rendered view in
      # views/layouts/application.erb, so it must follow super().
      @default_layout = :'layouts/application'
    end

    attr_reader :externals

    before do
      @csrf_token = request.cookies['csrf_token']
      unless @csrf_token
        @csrf_token = SecureRandom.hex(32)
        response.set_cookie('csrf_token', value: @csrf_token, path: '/')
      end
      # laptop_id identifies a browser profile, not a tab: it is a cookie, so
      # all tabs in one browser share it. This is deliberate. Mobbing detection
      # treats a different laptop_id as a different laptop, so opening a second
      # tab on the same kata just to read the instructions (a common case) must
      # not look like a second laptop. Sharing one laptop_id means the active
      # tab's committed events carry the reader tab's own id, so the read-side
      # poll's otherLaptopPresent predicate ignores them and shows no "mobbing?"
      # dialog. A separate browser profile or private window gets its own
      # laptop_id and is correctly treated as another laptop.
      @laptop_id = request.cookies['laptop_id']
      unless @laptop_id
        @laptop_id = SecureRandom.hex(32)
        response.set_cookie('laptop_id', value: @laptop_id, path: '/')
      end
      unless %w[GET HEAD OPTIONS TRACE].include?(request.request_method)
        token = request.env['HTTP_X_CSRF_TOKEN'] || params['authenticity_token']
        halt 403, 'Forbidden' unless token == @csrf_token
      end
    end

    # Compiled assets live in ${APP_DIR}/assets, a sibling of source/, populated
    # by the Dockerfile from the asset_builder stage. This mirrors ../creator
    # and ../dashboard and keeps the precompiled app.css/app.js out of the repo
    # tree.
    ASSETS_DIR = "#{ENV.fetch('APP_DIR')}/assets"

    def self.asset_path(filename)
      src = "#{ASSETS_DIR}/#{filename}"
      hash = Digest::SHA256.file(src).hexdigest[0, 8]
      base = File.basename(filename, '.*')
      ext  = File.extname(filename)
      "/assets/#{base}-#{hash}#{ext}"
    end

    CSS_PATH = asset_path('app.css')
    JS_PATH  = asset_path('app.js')

    # Collaborator shorthands, so the routes read as saver/runner/spooler
    # rather than externals.saver and friends.
    def runner
      externals.runner
    end

    def saver
      externals.saver
    end

    def spooler
      externals.spooler
    end

    def time
      externals.time
    end

    # View helpers, here rather than in one app, because the views are shared:
    # the review partials render from the review page and from the kata edit
    # page's review mode, so whichever app serves them must supply these.
    helpers do

      def partial(name)
        parts = name.split('/')
        parts[-1] = "_#{parts[-1]}"
        erb :"#{parts.join('/')}", layout: false
      end

      def j(str)
        str.to_s
          .gsub('\\') { '\\\\' }
          .gsub("\r\n") { '\\n' }
          .gsub("\n") { '\\n' }
          .gsub("\r") { '\\n' }
          .gsub('"') { '\\"' }
          .gsub("'") { "\\'" }
      end

    end

    # Every app answers an unmatched path the same way, because rack sends
    # each unmatched path to whichever app owns its prefix: /kata/nonsense
    # never reaches the app mounted at /. A hook rather than a get '*' route,
    # so it covers every verb and cannot shadow a route declared after it.
    not_found do
      status 404
      erb :'error/404', layout: :'layouts/error'
    end

    error do
      status 500
      erb :'error/500', layout: :'layouts/error'
    end

    private

    def id
      params[:id]
    end

    def index
      params[:index].to_i
    end

    # The id forwarded to saver on each event-write so it can stamp the writer
    # (mobbing detection). The browser sends its per-tab tab_id with the write;
    # the stored id is the laptop half (first 32 of the cookie) plus that
    # tab_id, so the read-side poll can tell one tab from another. A write
    # without a tab_id (an old or non-JS client) falls back to the plain cookie.
    def laptop_id
      tab_id = params['tab_id']
      tab_id ? @laptop_id[0, 32] + tab_id : @laptop_id
    end

    # This tab's monotonic write counter, forwarded to the spooler as the
    # tab_seq half of the idempotency key (laptop_id, tab_id, tab_seq). It
    # arrives as a form field (a string) but is an integer: the spooler orders
    # its buffer by tab_seq numerically, so it must be sent as an int, not a
    # string (else '10' < '2'). Absent OR blank (an old or non-JS client) yields
    # nil, which saver accepts - NOT 0, which ''.to_i would give and which is a
    # real seq value.
    def tab_seq
      raw = params['tab_seq']
      raw.to_s.empty? ? nil : raw.to_i
    end

  end
end
