
CyberDojo::Application.routes.draw do

  root :to => 'dojo#index'

  scope path: '/sha', controller: :sha do
    get 'index' => :index
  end

  scope path: '/dojo', controller: :dojo do
    get 'index(/:id)' => :index
  end

  scope path: '/individual', controller: :individual do
    get 'show(/:id)'      => :show
  end

  scope path: '/group', controller: :group do
    get 'show(/:id)'      => :show
  end

  scope path: '/setup_default_start_point', controller: :setup_default_start_point do
    get 'show(/:id)'      => :show
    get 'save_individual' => :save_individual # [1]
    get 'save_group'      => :save_group      # [1]
    post 'save_individual_json' => :save_individual_json, :constraints => { :format => :json }
    post 'save_group_json'      => :save_group_json,      :constraints => { :format => :json }
  end

  scope path: '/setup_custom_start_point', controller: :setup_custom_start_point do
    get 'show(/:id)'      => :show
    get 'save_individual' => :save_individual # [1]
    get 'save_group'      => :save_group      # [1]
    post 'save_individual_json' => :save_individual_json, :constraints => { :format => :json }
    post 'save_group_json'      => :save_group_json,      :constraints => { :format => :json }
  end

  scope path: '/kata', controller: :kata do
    get  'group(/:id)'      => :group
    get  'edit(/:id)'       => :edit
    get  'show_json(/:id)'  => :show_json
    post 'run_tests(/:id)'  => :run_tests
    get  'edit_offline'     => :edit_offline
  end

  scope path: '/id_join', controller: :id_join do
    get 'show(/:id)' => :show
    get 'drop_down'  => :drop_down,  :constraints => { :format => :json }
  end

  scope path: '/id_rejoin', controller: :id_rejoin do
    get 'show(/:id)' => :show
    get 'drop_down'  => :drop_down,  :constraints => { :format => :json }
  end

  scope path: '/id_review', controller: :id_review do
    get 'show'      => :show
    get 'drop_down' => :drop_down,  :constraints => { :format => :json }
  end

  scope path: '/forker', controller: :forker do
    get 'fork_individual(/:id)' => :fork_individual, :constraints => { :format => :json }
    get 'fork_group(/:id)'      => :fork_group,      :constraints => { :format => :json }
    get 'fork(/:id)' => :fork
  end

  scope path: '/dashboard', controller: :dashboard do
    get 'show(/:id)' => :show
    get 'progress'   => :progress,  :constraints => { :format => :json }
    get 'heartbeat'  => :heartbeat, :constraints => { :format => :json }
  end

  scope path: '/review', controller: :review do
    get 'show(/:id)' => :show
  end

  scope path: '/tipper', controller: :tipper do
    get 'traffic_light_tip' => :traffic_light_tip, :constraints => { :format => :json }
  end


  get '/differ/diff' => 'differ#diff', :constraints => { :format => :json }

  get '/reverter/revert' => 'reverter#revert', :constraints => { :format => :json }

  get '/download(/:id)' => 'downloader#download'
  get '/download_tag(/:id/:avatar/:tag)' => 'downloader#download_tag'

  # Backward compatibility
  # Used to explicitly start avatars to create prepared session

  scope path: '/enter', controller: :id_join do
    get 'start' => :drop_down, :constraints => { :format => :json }
  end

end

# [1] These four are get's and not post's
# This is because I want the creation of a new session to take
# you _directly_ to its URL, which includes the session-ID, eg
# /kata/edit/D46hN3
# Now, if the javascript issues an Ajax call which returns
# such a URL, then the browser will not, by default, allow
# redirection to that URL (cross-scripting).
# So it must be a plain non-ajax call.
