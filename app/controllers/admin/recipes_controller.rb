# app/controllers/admin/recipes_controller.rb
class Admin::RecipesController < Admin::ApplicationController
  def index
    @recipes = Recipe.all
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    if @recipe.save
      redirect_to admin_recipes_path, notice: "Recipe created successfully."
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
      redirect_to admin_recipes_path, notice: "Recipe updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    redirect_to admin_recipes_path, notice: "Recipe deleted successfully."
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :ingredients, :instructions, :image_url, :category)
  end
end
