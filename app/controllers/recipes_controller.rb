class RecipesController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]
  def index
    if params[:query].present?
      # Search for recipes and products based on query
      @recipes = Recipe.where("name ILIKE ? OR ingredients ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%").page(params[:page]).per(6)
      @products = Product.where("name ILIKE ? OR description ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
      
      # Use enhanced AI service for personalized recommendations
      @ai_results = AiRecipeService.get_personalized_recommendations(current_user, params[:query])
    else
      # Filter based on user preferences (if set)
      if current_user && current_user.preferences['favoriteCategories']
        # Use user preferences to filter recipes
        @recipes = Recipe.where(category: current_user.preferences['favoriteCategories']).page(params[:page]).per(6)
      else
        @recipes = Recipe.page(params[:page]).per(6)
      end

      @products = Product.none
      # Fetch personalized recommendations from AI if user is logged in
      if current_user
        @ai_results = AiRecipeService.get_personalized_recommendations(current_user)
      else
        @ai_results = nil
      end
    end
  end

  def show
    @recipe = Recipe.find_by_slug(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to recipes_path, alert: "Recipe not found."
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    if @recipe.save
      redirect_to @recipe, notice: "Recipe created successfully."
    else
      render :new
    end
  end

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Recipe updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    redirect_to recipes_path, notice: "Recipe deleted successfully."
  end

  def favorite
    @recipe = Recipe.find(params[:id])
    user_recipe = current_user.user_recipes.find_or_initialize_by(recipe: @recipe)
    user_recipe.favorite = !user_recipe.favorite
    user_recipe.save
    
    redirect_back(fallback_location: recipe_path(@recipe), notice: user_recipe.favorite ? 'Added to favorites!' : 'Removed from favorites.')
  end

  def rate
    @recipe = Recipe.find(params[:id])
    user_recipe = current_user.user_recipes.find_or_initialize_by(recipe: @recipe)
    user_recipe.rating = params[:rating]
    user_recipe.save
    
    redirect_back(fallback_location: recipe_path(@recipe), notice: 'Rating saved successfully!')
  end

  def review
    @recipe = Recipe.find(params[:id])
    user_recipe = current_user.user_recipes.find_or_initialize_by(recipe: @recipe)
    user_recipe.review = params[:review]
    user_recipe.save
    
    redirect_back(fallback_location: recipe_path(@recipe), notice: 'Review saved successfully!')
  end

  def search_by_ingredients
    ingredients = params[:ingredients]&.split(',')&.map(&:strip) || []
    @recipes = Recipe.where("ingredients ILIKE ANY (ARRAY[?])", ingredients.map { |i| "%#{i}%" })
    @ai_results = AiRecipeService.find_recipes_by_ingredients(ingredients, current_user)
  end

  def nutritional_analysis
    @recipe = Recipe.find(params[:recipe_id]) if params[:recipe_id]
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :ingredients, :instructions, :image_url, :category, :calories, :protein, :carbs, :fats, :fiber, :sugar, :sodium)
  end

  def authenticate_user!
    redirect_to '/login', alert: 'You need to be logged in to access this page.' unless session[:user_id]
  end
end
