# config/routes.rb
Rails.application.routes.draw do
  # Authentication routes
  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy', as: 'logout'
  get '/signup', to: 'registrations#new', as: 'new_user_registration'
  post '/signup', to: 'registrations#create', as: 'user_registration'

  # Static pages
  get '/about', to: 'pages#about'
  get '/contact', to: 'pages#contact'
  
  # User preferences
  get '/users/:user_id/preferences/edit', to: 'preferences#edit', as: 'edit_preferences'
  patch '/users/:user_id/preferences', to: 'preferences#update', as: 'update_preferences_user'
  
  # Main routes
  root 'recipes#index'
  
  # Recipes with enhanced features
  resources :recipes do
    member do
      post :favorite
      post :rate
      post :review
    end
    collection do
      get :test_openai_service
      get :search_by_ingredients
      get :nutritional_analysis
    end
  end
  
  # Meal Planning
  resources :meal_plans do
    collection do
      get :generate_ai_plan
      post :generate_ai_plan
      post :create_from_ai
    end
  end
  
  # Grocery Lists
  resources :grocery_lists do
    member do
      patch :mark_item_completed
      patch :mark_item_incomplete
    end
    collection do
      get :generate_from_meal_plan
      post :generate_from_meal_plan
    end
  end
  
  # AI Features
  get '/ai/ingredient_search', to: 'ai_features#ingredient_search', as: 'ai_ingredient_search'
  post '/ai/ingredient_search', to: 'ai_features#ingredient_search'
  
  get '/ai/nutrition_analysis', to: 'ai_features#nutrition_analysis', as: 'ai_nutrition_analysis'
  post '/ai/nutrition_analysis', to: 'ai_features#nutrition_analysis'
  
  get '/ai/meal_planning', to: 'ai_features#meal_planning', as: 'ai_meal_planning'
  post '/ai/meal_planning', to: 'ai_features#meal_planning'
  
  get '/ai/diet_advice', to: 'ai_features#diet_advice', as: 'ai_diet_advice'
  post '/ai/diet_advice', to: 'ai_features#diet_advice'
  
  get '/ai/recipe_modification', to: 'ai_features#recipe_modification', as: 'ai_recipe_modification'
  post '/ai/recipe_modification', to: 'ai_features#recipe_modification'
  
  # User Recipe Interactions
  resources :user_recipes, only: [:create, :update, :destroy]
end