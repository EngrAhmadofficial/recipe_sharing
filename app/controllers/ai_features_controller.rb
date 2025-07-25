class AiFeaturesController < ApplicationController
  before_action :authenticate_user!

  def ingredient_search
    if request.post?
      ingredients = params[:ingredients]&.split(',')&.map(&:strip) || []
      
      if ingredients.any?
        @ai_results = AiRecipeService.find_recipes_by_ingredients(ingredients, current_user)
      else
        @ai_results = { error: "Please provide at least one ingredient." }
      end
    end
  end

  def nutrition_analysis
    if request.post?
      recipe_data = params[:recipe_data]
      
      if recipe_data.present?
        @ai_results = AiRecipeService.analyze_nutrition(recipe_data)
      else
        @ai_results = { error: "Please provide recipe data for analysis." }
      end
    end
  end

  def meal_planning
    if request.post?
      days = params[:days]&.to_i || 7
      goal = params[:goal] || 'healthy_eating'
      preferences = params[:preferences] || {}
      
      begin
        @ai_results = AiRecipeService.generate_meal_plan(current_user, days, preferences)
        flash.now[:notice] = "Meal plan generated successfully!"
      rescue => e
        Rails.logger.error("Error generating meal plan: #{e.message}")
        @ai_results = { error: "Failed to generate meal plan: #{e.message}" }
        flash.now[:alert] = "Failed to generate meal plan: #{e.message}"
      end
    end
  end

  def diet_advice
    if request.post?
      goal = params[:goal]
      
      if goal.present?
        @ai_results = AiRecipeService.get_diet_advice(current_user, goal)
      else
        @ai_results = { error: "Please specify your diet goal." }
      end
    end
  end

  def recipe_modification
    if request.post?
      recipe_id = params[:recipe_id]
      
      if recipe_id.present?
        recipe = Recipe.find(recipe_id)
        @ai_results = AiRecipeService.modify_recipe_for_diet(recipe, current_user)
      else
        @ai_results = { error: "Please select a recipe to modify." }
      end
    end
    
    @recipes = Recipe.all
  end

  private

  def authenticate_user!
    redirect_to '/login', alert: 'You need to be logged in to access this page.' unless session[:user_id]
  end
end
