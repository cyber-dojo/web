require_relative 'app_base'

module WebApp
  # The two compiled bundles, served straight from ${APP_DIR}/assets.
  class AssetsApp < AppBase

    # Where this app mounts itself. Named here so config.ru and the tests
    # mount it identically. AppBase builds the paths the views link to, and
    # rack strips this prefix from them, so each route below is what is left
    # of its path: /assets/app-1a2b3c4d.css arrives as /app-1a2b3c4d.css.
    MOUNT_PATH = '/assets'.freeze

    get CSS_PATH.delete_prefix(MOUNT_PATH) do
      cache_control :public, max_age: 31536000, immutable: true
      content_type 'text/css'
      send_file "#{ASSETS_DIR}/app.css"
    end

    get JS_PATH.delete_prefix(MOUNT_PATH) do
      cache_control :public, max_age: 31536000, immutable: true
      content_type 'text/javascript'
      send_file "#{ASSETS_DIR}/app.js"
    end

  end
end
