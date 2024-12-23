# app/controllers/recipes_controller.rb
class RecipesController < ApplicationController

  def index
    if params[:query].present?
      # Perform database search for matching recipes
      @recipes = Recipe.where("name ILIKE ? OR ingredients ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%").page(params[:page]).per(6)

      @products = Product.where("name ILIKE ? OR description ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
      # Perform AI-based search and retrieve recommendations
      @ai_results = OpenAiService.search_recipes(params[:query], @recipes, @products)
    else
      # Load all recipes with pagination if no query is present
      @recipes = Recipe.page(params[:page]).per(6)
      @products = Product.none
      @ai_results = nil
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

  private

  def recipe_params
    params.require(:recipe).permit(:name, :ingredients, :instructions, :image_url, :category)
  end
end
