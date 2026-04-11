# Porting cyber-dojo/web to Plain Sinatra

## Current Stack

The app runs Rails 8.0.1 but uses almost none of Rails' signature features:

- No ActiveRecord / no database (all persistence via the `saver` microservice over HTTP/JSON)
- No Action Mailer, no Active Job, no Action Cable
- Only two Rails components are required in `application.rb`: `action_controller/railtie` and `sprockets/railtie`
- Three routes (`/alive`, `/ready`, `/web/sha`) are already written as plain Rack lambdas
- The `Externals` mixin (dependency injection), models, and all services are pure Ruby with no Rails coupling

The dependency on Rails is almost entirely about:
1. **`ActionController::Base`** — parameter parsing, `respond_to`, `render`, `protect_from_forgery`, CSRF helpers, `rescue_from`
2. **Sprockets** — compiling/fingerprinting 53 SCSS files and bundling ~25 JS files
3. **`ActionDispatch::IntegrationTest`** — the controller test base class

---

## What a Sinatra Port Looks Like

### Routing (trivial)

The routes file has 11 routes total. They map directly to Sinatra:

```ruby
get  '/alive'     { [200, {'Content-Type'=>'application/json'}, [{'alive?'=>true}.to_json]] }
get  '/ready'     { ... }
get  '/web/sha'   { ... }
get  '/kata/edit/:id'         { erb :'kata/edit' }
post '/kata/run_tests/:id'    { content_type :js; erb :'kata/run_tests', layout: false }
post '/kata/checkout'         { content_type :json; ... }
post '/kata/revert'           { ... }
post '/kata/file_create'      { ... }
post '/kata/file_delete'      { ... }
post '/kata/file_rename'      { ... }
post '/kata/file_edit'        { ... }
get  '/review/show/:id'       { erb :'review/show' }
get  '*'                      { status 404; erb :'error/404', layout: :error }
```

Sinatra supports ERB via Tilt natively, so the view files themselves need minimal changes.

### Controllers → Route Handlers

**`KataController`** is 265 lines. The logic is entirely portable:
- `params`, `render json:`, `respond_to` → use Sinatra's `params`, `content_type :json`, `halt`
- `Rack::Utils.parse_nested_query` is already Rack, not Rails — no change needed
- `protect_from_forgery` → replace with a before-filter checking `env['HTTP_X_CSRF_TOKEN']` or the standard Rack CSRF middleware (`rack-protection` gem, which Sinatra includes by default)

**`ApplicationController`** rescue handlers → Sinatra `error` blocks:
```ruby
error 404 { erb :'error/404', layout: :error }
error 500 { erb :'error/500', layout: :error }
```

**`ReviewController`** is trivial (8 lines of logic) — direct translation.

### Views (low effort, high volume)

ERB templates work identically under Sinatra via Tilt. The main differences:

| Rails helper | Sinatra equivalent |
|---|---|
| `csrf_meta_tag` | manual `<meta name="csrf-token" content="<%= env['rack.session'][:csrf] %>">` (or `rack-protection` helpers) |
| `stylesheet_link_tag :application` | `<link rel="stylesheet" href="/assets/application.css">` (static path post-compilation) |
| `javascript_include_tag :application` | `<script src="/assets/application.js">` |
| `render partial: 'foo'` | `erb :'_foo'` or extracted to a helper method |
| `raw(x)` / `j raw(x)` | Sinatra ERB does not HTML-escape by default; `j` can be a simple helper using `ERB::Util.json_escape` |

The 26 shared partials and ~20 kata/review partials each need a `render partial:` call replaced, but the template content itself is unchanged. This is mechanical work.

The one non-trivial view is **`run_tests.js.erb`** — it renders JavaScript with embedded Ruby. In Sinatra, this works fine: set `content_type 'application/javascript'` and render the template without a layout. No structural change needed.

### Asset Pipeline (done)

Rails Sprockets previously compiled 53 SCSS files and bundled ~25 JS files at runtime.

This has been replaced with the same pre-build pattern used in the `../dashboard` repo:

- A dedicated `cyberdojo/asset_builder` Docker service volume-mounts the source
  `stylesheets/` and `javascripts/` directories, compiles them using Sprockets+SassC,
  and serves the result over HTTP.
- `bin/build_assets.sh` starts that container, curls `/assets/app.css` and
  `/assets/app.js`, and writes the compiled output to `source/public/assets/`.
- The compiled files are **committed to the repo**. CI just runs `docker build`; no
  asset compilation happens in the pipeline.
- The layout templates now use plain `<link>` and `<script>` tags pointing to
  `/assets/app.css` and `/assets/app.js`. Rails serves them as static files from
  `public/` (`config.public_file_server.enabled = true` was already set).
- `make image` now depends on `make assets`, so local builds always recompile first.

Entry points for the asset_builder:
- `source/app/assets/stylesheets/app.css` — `//= require ./application` (which pulls in `application.scss` and its `@import` chain)
- `source/app/assets/javascripts/app.js` — the Sprockets manifest (renamed from `application.js`), preserving the CodeMirror load order

### Tests (moderate effort)

The test suite uses `ActionDispatch::IntegrationTest` as the base class for all 16 controller tests. This is the Rails-specific part.

The equivalent in Sinatra is `Rack::Test` (via the `rack-test` gem):

```ruby
# Current (Rails)
class AppControllerTestBase < ActionDispatch::IntegrationTest
  def post_json(path, params)
    post path, params: params
    assert_response :success, response.body
  end
end

# Sinatra equivalent
require 'rack/test'
class AppControllerTestBase < Minitest::Test
  include Rack::Test::Methods
  def app = MyApp
  def post_json(path, params)
    post path, params.to_json, 'CONTENT_TYPE' => 'application/json'
    assert last_response.ok?, last_response.body
  end
end
```

The `in_kata` helper, stub infrastructure (`TestExternalHelpers`, `runner_stub.rb`), and all the domain helpers are framework-agnostic and need no changes.

The 6 model/service test files are pure Minitest with no Rails coupling — zero changes needed.

### Sessions and CSRF

The app uses Rails' cookie session store (`_blog_session`) but does not actually store anything meaningful in the session — it is only there to satisfy CSRF token generation. The CSRF token is read by `jquery_ujs.js` from the `csrf-meta-tag`.

In Sinatra, `rack-protection` (included by default) provides CSRF protection. The cookie session moves to `Rack::Session::Cookie`. The jQuery UJS CSRF integration continues to work as long as the meta tag is present with the correct token.

### Dockerfile

The current `FROM` line is `cyberdojo/web-base` which carries Rails, `sassc-rails`,
`uglifier`, and `nodejs`. All of that goes away.

The new `FROM` line uses the same base image as all other Sinatra services:

```dockerfile
FROM ghcr.io/cyber-dojo/sinatra-base:3ce6c9b@sha256:7e53acc4239e11722997e85367eb8e995d995ceec05f1cc6430da989bb09b108
```

`sinatra-base` already contains:
- `sinatra`, `sinatra-contrib`, `rack`, `rack-test`, `puma`
- `sprockets` (for the asset_builder service — not needed at runtime in web)
- `minitest`, `minitest-ci`, `minitest-reporters`, `simplecov`
- `json`, `oj`, `rest-client`, `prometheus-client`
- Security upgrades for `expat`, `c-ares`, `openssl` (already baked in)
- `tini`, `bash`, `curl`, `tar`

The web app only needs `net/http` and `uri` beyond this (both stdlib) for its
service calls to saver/runner/differ.

The `RUN apk add --upgrade expat` and `RUN apk add --upgrade nodejs` lines in the
current Dockerfile both disappear: `expat` is already upgraded inside `sinatra-base`,
and `nodejs` was only needed for the Rails asset pipeline.

Following the dashboard pattern, the Dockerfile also gains an `APP_DIR` build arg,
drops `EXPOSE 3000`, and the `COPY` becomes:

```dockerfile
ARG APP_DIR=/web
ENV APP_DIR=${APP_DIR}

WORKDIR ${APP_DIR}/source
COPY source/ .
```

### The `Externals` Module

This is already framework-agnostic. It uses `ENV` variables and `Object.const_get` to inject service classes. It will work unchanged in Sinatra — just `include Externals` in the Sinatra app class instead of in `ApplicationController`.

---

## Work Inventory

| Area | Effort | Notes |
|---|---|---|
| `app.rb` / `config.ru` skeleton | Small | ~50 lines to replace Rails boot |
| Routes | Trivial | 11 routes, direct translation |
| Controller logic | Small | ~300 lines of pure Ruby, minimal Rails API surface |
| ERB views — content | None | Templates are unchanged |
| ERB views — helpers (`render partial`, `raw`, `csrf_meta_tag`) | Small–Medium | Mechanical substitution across ~50 files |
| Asset pipeline | **Done** | asset_builder service; pre-built CSS/JS committed to repo; static `<link>`/`<script>` tags in layouts |
| Controller tests (16 files) | Medium | Replace `ActionDispatch::IntegrationTest` with `Rack::Test`; `post_json` helper needs update |
| Model/service tests (14 files) | None | Pure Minitest, no Rails coupling |
| CSRF / session setup | Small | `rack-protection` + `Rack::Session::Cookie` |
| `Gemfile` | Trivial | Drop `rails`, `sassc-rails`; add `sinatra`, `rack-protection`, `rack-test` |
| Docker / `up.sh` | Trivial | Change `FROM cyberdojo/web-base` to `FROM ghcr.io/cyber-dojo/sinatra-base`; drop `nodejs` and security-upgrade `RUN` lines already baked into sinatra-base; replace `rails server` with puma via `up.sh` |

**Overall assessment:** This is a straightforward port. The codebase is already thinly coupled to Rails, and the asset pipeline — the one real decision point — is now done. Everything remaining is mechanical.

The primary benefit of the port would be a significantly smaller runtime dependency (Sinatra + Rack vs Rails), faster boot time, and a more explicit application structure with no Rails magic.

## Summary

The port is complete. The app runs on Sinatra 4.x + Puma + Rack, with no Rails dependency.

---

## Runtime Gotchas

A few non-obvious issues found during the bring-up that are worth documenting.

### 1. Puma rackup path: `__dir__` vs the file location

`source/config/puma.rb` is one directory below `source/config.ru`. Using a bare
relative path fails:

```ruby
# Wrong — looks for source/config/config.ru (doesn't exist)
rackup "#{__dir__}/config.ru"

# Right — resolves one level up from source/config/ to source/
rackup File.expand_path('../config.ru', __dir__)
```

### 2. `Rack::Session::Cookie` secret must be ≥ 64 bytes

Rack enforces a minimum 64-byte secret at startup. The dev fallback must meet that:

```ruby
secret: ENV.fetch('SECRET_KEY_BASE', 'cyber-dojo-dev-secret-key-base-must-be-at-least-64-bytes-long!!!')
```

### 3. `set :layout` in Sinatra 4.x does NOT change the default layout

`set :layout, :'layouts/application'` creates a class-level method called `layout`
that returns the symbol — but Sinatra's render engine reads `@default_layout`, an
**instance variable** on the request handler that is always initialised to `:layout`
(looking for `views/layout.erb`). Since `views/layout.erb` doesn't exist, Sinatra
silently skips the layout, and the response is the bare body content with no `<head>`
and no `<script src="/assets/app.js">` — causing "$ is not defined" in the browser.

The fix: override `initialize` to set `@default_layout` correctly.

```ruby
class App < Sinatra::Base
  def initialize
    super
    @default_layout = :'layouts/application'
  end
  ...
end
```

### 4. Asset serving — use the dashboard pattern

`Sinatra::Base` does not serve static files from `public/` by default (unlike
top-level Sinatra DSL). `set :static, true` and `set :public_folder` can be enabled,
but the more reliable approach — already used in the `dashboard` service — is to
read the compiled files into constants at class load time and expose them via
explicit GET routes:

```ruby
PUBLIC_DIR = File.expand_path('../public', __dir__)
CSS = File.read("#{PUBLIC_DIR}/assets/app.css")
JS  = File.read("#{PUBLIC_DIR}/assets/app.js")

get '/assets/app.css' do
  content_type 'text/css'
  CSS
end

get '/assets/app.js' do
  content_type 'application/javascript'
  JS
end
```

### 5. `create_v2_kata.sh` — path and TTY flag

With `APP_DIR=/web` and `WORKDIR /web/source`, the script moved from the old
`/cyber-dojo/script/` path. Also, `docker exec -it` requires a TTY; removing `-t`
allows the script to run non-interactively (e.g., captured into a shell variable):

```bash
# Wrong
docker exec -it test_web bash -c 'ruby /cyber-dojo/script/create_v2_kata.rb'

# Right
docker exec test_web bash -c 'ruby /web/source/script/create_v2_kata.rb'
```