Rtp::Application.routes.draw do

  # resources
  resources :user_sessions, only: [ :new, :create, :destroy ]

  resources :events do
    collection do
      post 'search'
    end
  end

  resources :tasks do
    collection do
      post 'reschedule'
      post 'search'
    end

    member do
      post 'schedule'
    end
  end

  resources :task_events, only: [ :index, :show ] do
    collection do
      get 'tags'
    end
  end

  resources :calendars, only: [ :index ] do
    member do
      get 'preferences'
      put 'preferences' => 'calendars#update_preferences'
      post 'add_task'
    end
  end

  resources :users, except: [ :index ] do
    resources :preferences, except: [ :destroy, :index ]
  end

  # root and matches
  root 'static_pages#welcome'
  get '/signup',   to: 'users#new'
  get '/help',     to: 'static_pages#help'
  get '/settings', to: 'static_pages#settings'
  get '/signin',   to: 'user_sessions#new'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
