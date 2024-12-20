# config/routes.rb
Rails.application.routes.draw do

  resources :recipes do
    member do
      post :upvote
    end
  end
  get "pages/about"
  get "pages/contact"
  devise_for :users
  root 'recipes#index'
  get '/about', to: 'pages#about'
  get '/contact', to: 'pages#contact'
  get '/subscription', to: 'subscriptions#new'

  namespace :admin do
    resources :recipes
    root 'dashboard#index'
  end
end