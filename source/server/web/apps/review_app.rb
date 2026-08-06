require_relative 'app_base'

module Web
  # The review page as a page in its own right, opened from a dashboard
  # traffic-light. The same page is also a mode of the kata edit page, which
  # renders views/review/_review.erb into a hidden div and reveals it
  # client-side; that mode never reaches this app. The partials tell the two
  # apart by DOM, not by URL (#kata-page present or not), so they render
  # identically whichever app serves them.
  class ReviewApp < AppBase

    # Where this app mounts itself. Named here so config.ru and the tests
    # mount it identically. Rack strips it, so /review/show/:id arrives as
    # /show/:id.
    MOUNT_PATH = '/review'.freeze

    get '/show/:id' do
      @runtime_env = ENV
      @id = params[:id]
      @manifest = saver.kata_manifest(@id)
      @title = "review:#{@id}"
      erb :'review/show'
    end

  end
end
