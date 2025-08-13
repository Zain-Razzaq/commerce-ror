Rails.application.routes.draw do
  root "products#index"
  resources :products, except: [:new, :edit] do
    collection do
      get '/search', to: 'products#search'
      post '/by-ids', to: 'products#by_ids'
    end
  end
  
  resources :categories, except: [:new, :edit, :show]
  resources :users, except: [:new, :edit]
  resources :sessions, only: [:create, :destroy]

  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  post "/signup", to: "users#create"

  resource :cart, only: [:show, :update]
  resources :cart_items, only: [:create, :update, :destroy]
  resources :orders, only: [:index, :create, :destroy, :update] do
    collection do
      get '/user-orders', to: 'orders#user_orders'
    end
  end
end
