Rails.application.routes.draw do
  root "products#index"
  resources :products, except: [:new, :edit]
  resources :categories, except: [:new, :edit, :show]
  resources :users, except: [:new, :edit]
  resources :sessions, only: [:create, :destroy]
end
