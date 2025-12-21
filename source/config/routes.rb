
def json_triple(data)
  [ 200, {"Content-Type" => "application/json"}, [data.to_json] ]
end

CyberDojo::Application.routes.draw do

  get '/alive'  ,        to: proc { json_triple(    'alive?' => true      ) }
  get '/ready'  ,        to: proc { json_triple(    'ready?' => true      ) }
  get '/web/sha',        to: proc { json_triple(       'sha' => ENV['SHA']) }

  scope path: '/kata', controller: :kata do
    get  'edit(/:id)'        => :edit
    post 'run_tests(/:id)'   => :run_tests,   :constraints => { :format => :json }
    post 'checkout'          => :checkout,    :constraints => { :format => :json }
    post 'revert'            => :revert,      :constraints => { :format => :json }
    post 'file_switch'       => :file_switch, :constraints => { :format => :json }
  end

  scope path: '/review', controller: :review do
    get 'show(/:id)' => :show
  end

  get '*path', to: 'error#render_404', via: :all

end
