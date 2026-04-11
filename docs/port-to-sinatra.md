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
| Docker / `up.sh` | Trivial | Replace `rails server` with `rackup` or `ruby app.rb` |

**Overall assessment:** This is a straightforward port. The codebase is already thinly coupled to Rails, and the asset pipeline — the one real decision point — is now done. Everything remaining is mechanical.

The primary benefit of the port would be a significantly smaller runtime dependency (Sinatra + Rack vs Rails), faster boot time, and a more explicit application structure with no Rails magic.

## Summary

The app is already very thinly coupled to Rails.
It uses no ActiveRecord, no mailer, no background jobs, and no database.
The remaining Rails surface area is:
1. ActionController::Base — parameter parsing, render, protect_from_forgery, rescue_from
2. ActionDispatch::IntegrationTest — used in the 16 controller test files

The asset pipeline — previously the one real decision point — is done. The
`cyberdojo/asset_builder` service pre-compiles SCSS and JS; the output is committed
to the repo and served as static files. Rails magic is no longer involved in asset serving.

Remaining work:

- Routes, controller logic, models, services: trivial — all pure Ruby
- ERB views: no content changes, just mechanical substitution of `render partial:`, `raw`, `csrf_meta_tag` across ~50 files
- Controller tests: replace `ActionDispatch::IntegrationTest` with `Rack::Test` (16 files)
- Model/service tests: zero changes needed

This is a manageable, low-risk port — mostly mechanical work with no remaining architectural decisions.