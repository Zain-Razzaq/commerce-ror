Rails.application.routes.draw do
  root "products#index"
  resources :products, except: [:new, :edit] do
    collection do
      get '/search', to: 'products#search'
    end
  end
  
  resources :categories, except: [:new, :edit, :show]
  resources :users, except: [:new, :edit]
  resources :sessions, only: [:create, :destroy]

  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  post "/signup", to: "users#create"
end
