
def json_triple(data)
  [ 200, {"Content-Type" => "application/json"}, [data.to_json] ]
end

CyberDojo::Application.routes.draw do

  get '/alive'  , to: proc { json_triple("alive?" => true      ) }
  get '/ready'  , to: proc { json_triple("ready?" => true      ) }
  get '/web/sha', to: proc { json_triple(   "sha" => ENV['SHA']) }

  root :to => 'dojo#index'

  scope path: '/dojo', controller: :dojo do
    get 'index(/:id)' => :index
  end

  scope path: '/individual', controller: :individual do
    get 'show(/:id)'      => :show
  end

  scope path: '/group', controller: :group do
    get 'show(/:id)'      => :show
  end

  scope path: '/kata', controller: :kata do
    get  'group(/:id)'      => :group
    get  'edit(/:id)'       => :edit
    get  'show_json(/:id)'  => :show_json
    post 'run_tests(/:id)'  => :run_tests
    post 'set_theme'        => :set_theme
    post 'set_colour'       => :set_colour
    post 'set_predict'      => :set_predict
    get  'edit_offline'     => :edit_offline
  end

  scope path: '/id_join', controller: :id_join do
    get 'show(/:id)' => :show
    post 'join'      => :join, :constraints => { :format => :json }
    get 'drop_down' => :drop_down,  :constraints => { :format => :json } # deprecated
  end

  scope path: '/id_rejoin', controller: :id_rejoin do
    get 'show(/:id)' => :show
    post 'rejoin'    => :rejoin, :constraints => { :format => :json }
    get 'drop_down' => :drop_down,  :constraints => { :format => :json } # deprecated
  end

  scope path: '/id_review', controller: :id_review do
    get 'show'      => :show
    post 'review'   => :review, :constraints => { :format => :json }
    get 'drop_down' => :drop_down,  :constraints => { :format => :json } # deprecated
  end

  scope path: '/forker', controller: :forker do
    get 'fork_individual(/:id)' => :fork_individual
    get 'fork_group(/:id)'      => :fork_group
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

  post '/reverter/revert' => 'reverter#revert', :constraints => { :format => :json }

  get '/download(/:id)' => 'downloader#download'
  get '/download_tag(/:id/:avatar/:tag)' => 'downloader#download_tag'

  # Used to explicitly start avatars to create prepared session

  scope path: '/enter', controller: :id_join do
    get 'start' => :drop_down, :constraints => { :format => :json }
  end

end
