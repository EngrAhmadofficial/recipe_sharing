# config/routes.rb
Rails.application.routes.draw do


  get "pages/about"
  get "pages/contact"
  resources :recipes, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  root 'recipes#index'
  # get '/products' to: 'product#index'
  get '/about', to: 'pages#about'
  get '/contact', to: 'pages#contact'
  resources :recipes do
    collection do
      get :test_openai_service
    end
  end

end