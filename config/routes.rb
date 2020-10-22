
def json_triple(data)
  [ 200, {"Content-Type" => "application/json"}, [data.to_json] ]
end

CyberDojo::Application.routes.draw do

  get '/alive'  , to: proc { json_triple("alive?" => true      ) }
  get '/ready'  , to: proc { json_triple("ready?" => true      ) }
  get '/web/sha', to: proc { json_triple(   "sha" => ENV['SHA']) }

  scope path: '/kata', controller: :kata do
    get  'edit(/:id)'       => :edit
    post 'run_tests(/:id)'  => :run_tests
    post 'set_theme'        => :set_theme
    post 'set_colour'       => :set_colour
    post 'set_predict'      => :set_predict
  end

  scope path: '/forker', controller: :forker do
    get 'fork_individual(/:id)' => :fork_individual
    get 'fork_group(/:id)'      => :fork_group
  end

  scope path: '/dashboard', controller: :dashboard do
    get 'show(/:id)' => :show
    get 'progress'   => :progress,  :constraints => { :format => :json }
    get 'heartbeat'  => :heartbeat, :constraints => { :format => :json }
  end

  scope path: '/review', controller: :review do
    get 'show(/:id)' => :show
  end

  get '/differ/diff' => 'differ#diff', :constraints => { :format => :json }

  post '/reverter/revert' => 'reverter#revert', :constraints => { :format => :json }

end
