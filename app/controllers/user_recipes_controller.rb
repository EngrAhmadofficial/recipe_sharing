class UserRecipesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_recipe, only: [:update, :destroy]

  def create
    @user_recipe = current_user.user_recipes.build(user_recipe_params)
    
    if @user_recipe.save
      redirect_back(fallback_location: recipe_path(@user_recipe.recipe), notice: 'Recipe interaction saved successfully.')
    else
      redirect_back(fallback_location: recipe_path(@user_recipe.recipe), alert: 'Failed to save interaction.')
    end
  end

  def update
    if @user_recipe.update(user_recipe_params)
      redirect_back(fallback_location: recipe_path(@user_recipe.recipe), notice: 'Recipe interaction updated successfully.')
    else
      redirect_back(fallback_location: recipe_path(@user_recipe.recipe), alert: 'Failed to update interaction.')
    end
  end

  def destroy
    recipe = @user_recipe.recipe
    @user_recipe.destroy
    redirect_back(fallback_location: recipe_path(recipe), notice: 'Recipe interaction removed successfully.')
  end

  private

  def set_user_recipe
    @user_recipe = current_user.user_recipes.find(params[:id])
  end

  def user_recipe_params
    params.require(:user_recipe).permit(:recipe_id, :rating, :review, :favorite)
  end

  def authenticate_user!
    redirect_to '/login', alert: 'You need to be logged in to access this page.' unless session[:user_id]
  end
end 