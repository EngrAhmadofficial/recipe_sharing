class GroceryListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_grocery_list, only: [:show, :edit, :update, :destroy, :mark_item_completed, :mark_item_incomplete]

  def index
    @grocery_lists = current_user.grocery_lists.order(created_at: :desc)
  end

  def show
  end

  def new
    @grocery_list = current_user.grocery_lists.build
  end

  def create
    @grocery_list = current_user.grocery_lists.build(grocery_list_params)
    
    if @grocery_list.save
      redirect_to @grocery_list, notice: 'Grocery list created successfully.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @grocery_list.update(grocery_list_params)
      redirect_to @grocery_list, notice: 'Grocery list updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @grocery_list.destroy
    redirect_to grocery_lists_path, notice: 'Grocery list deleted successfully.'
  end

  def mark_item_completed
    item_name = params[:item_name]
    if @grocery_list.mark_item_completed(item_name)
      redirect_to @grocery_list, notice: 'Item marked as completed.'
    else
      redirect_to @grocery_list, alert: 'Failed to mark item as completed.'
    end
  end

  def mark_item_incomplete
    item_name = params[:item_name]
    if @grocery_list.mark_item_incomplete(item_name)
      redirect_to @grocery_list, notice: 'Item marked as incomplete.'
    else
      redirect_to @grocery_list, alert: 'Failed to mark item as incomplete.'
    end
  end

  def generate_from_meal_plan
    @meal_plans = current_user.meal_plans.order(:date, :meal_type)

    if request.post?
      selected_ids = params[:meal_plan_ids] || []
      selected_meal_plans = @meal_plans.where(id: selected_ids)
      # Collect all ingredients from recipes and from meal plans directly
      recipe_ingredients = selected_meal_plans.map(&:recipe).compact.flat_map { |r| r.ingredients.is_a?(Array) ? r.ingredients : (r.ingredients.to_s.split(',').map(&:strip)) }
      plan_ingredients = selected_meal_plans.select { |plan| plan.recipe.nil? && plan.ingredients.present? }.flat_map do |plan|
        plan.ingredients.is_a?(Array) ? plan.ingredients : plan.ingredients.to_s.split(',').map(&:strip)
      end
      all_ingredients = (recipe_ingredients + plan_ingredients).uniq

      if selected_ids.empty?
        @ai_grocery_list = { error: "No meal plans selected. Please select at least one meal plan." }
      elsif all_ingredients.empty?
        @ai_grocery_list = { error: "The selected meal plans do not have any ingredients or recipes associated. Please select meal plans with ingredient data." }
      else
        # Use the AI service to generate a grocery list from all_ingredients
        @ai_grocery_list = AiRecipeService.generate_grocery_list_from_ingredients(all_ingredients, current_user)
        Rails.logger.info("AI Grocery List: \n#{@ai_grocery_list.inspect}")
      end
      render :generate_from_meal_plan
    else
      render :generate_from_meal_plan
    end
  end

  private

  def set_grocery_list
    @grocery_list = current_user.grocery_lists.find(params[:id])
  end

  def grocery_list_params
    params.require(:grocery_list).permit(:name, :items, :completed)
  end

  def authenticate_user!
    redirect_to '/login', alert: 'You need to be logged in to access this page.' unless session[:user_id]
  end
end
