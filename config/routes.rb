
CyberDojo::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'dojo#index'

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

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
    get 'save_individual' => :save_individual
    get 'save_group'      => :save_group
    post 'save_individual_json' => :save_individual_json, :constraints => { :format => :json }
    post 'save_group_json'      => :save_group_json,      :constraints => { :format => :json }
  end

  scope path: '/setup_custom_start_point', controller: :setup_custom_start_point do
    get 'show(/:id)'      => :show
    get 'save_individual' => :save_individual
    get 'save_group'      => :save_group
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


  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id))(.:format)'

end
