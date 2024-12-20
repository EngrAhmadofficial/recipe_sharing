# app/controllers/recipes_controller.rb
class RecipesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
    if params[:query].present?
      @recipes = Recipe.where("name ILIKE ? OR ingredients ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%").page(params[:page]).per(6)
    else
      @recipes = Recipe.page(params[:page]).per(6)
    end
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


  def upvote
    @recipe = Recipe.find(params[:id])
    @recipe.upvote_by current_user
    redirect_to recipe_path(@recipe), notice: "You liked this recipe!"
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :ingredients, :instructions, :image_url, :category)
  end
end
