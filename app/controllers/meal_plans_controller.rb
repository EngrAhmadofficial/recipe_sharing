class MealPlansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meal_plan, only: [:show, :edit, :update, :destroy]

  def index
    @meal_plans = current_user.meal_plans.includes(:recipe).order(:date, :meal_type)
    @weekly_plans = @meal_plans.group_by { |plan| plan.date.beginning_of_week }
  end

  def show
  end

  def new
    @meal_plan = current_user.meal_plans.build
    @recipes = Recipe.all
  end

  def create
    @meal_plan = current_user.meal_plans.build(meal_plan_params)
    
    if @meal_plan.save
      redirect_to @meal_plan, notice: 'Meal plan created successfully.'
    else
      @recipes = Recipe.all
      render :new
    end
  end

  def edit
    @recipes = Recipe.all
  end

  def update
    if @meal_plan.update(meal_plan_params)
      redirect_to @meal_plan, notice: 'Meal plan updated successfully.'
    else
      @recipes = Recipe.all
      render :edit
    end
  end

  def destroy
    @meal_plan.destroy
    redirect_to meal_plans_path, notice: 'Meal plan deleted successfully.'
  end

  def generate_ai_plan
    if request.post?
      days = params[:days]&.to_i || 7
      preferences = params[:preferences] || {}
      
      @ai_plan = AiRecipeService.generate_meal_plan(current_user, days, preferences)
      
      if @ai_plan.is_a?(Hash) && @ai_plan[:error]
        redirect_to meal_plans_path, alert: @ai_plan[:error]
      else
        render :generate_ai_plan
      end
    else
      render :generate_ai_plan
    end
  end

  def create_from_ai
    meal_plan_json = params[:meal_plan_json]
    if meal_plan_json.blank?
      redirect_to generate_ai_plan_meal_plans_path, alert: 'No meal plan data provided.' and return
    end

    begin
      meal_plan = JSON.parse(meal_plan_json)
      ActiveRecord::Base.transaction do
        meal_plan['meal_plan'].each do |day|
          days_of_week = %w[monday tuesday wednesday thursday friday saturday sunday]
          date = Date.today + days_of_week.index(day['day'].downcase)
          %w[breakfast lunch dinner].each do |meal_type|
            meal = day['meals'][meal_type]
            next unless meal
            MealPlan.create!(
              user: current_user,
              date: date,
              meal_type: meal_type,
              name: meal['name'],
              calories: meal['calories'],
              protein: meal['protein'],
              carbs: meal['carbs'],
              fats: meal['fats'],
              ingredients: meal['ingredients'],
              instructions: meal['instructions']
            )
          end
        end
      end
      redirect_to meal_plans_path, notice: 'Meal plan saved successfully!'
    rescue => e
      Rails.logger.error("Failed to save AI meal plan: #{e.message}")
      redirect_to generate_ai_plan_meal_plans_path, alert: 'Failed to save meal plan.'
    end
  end

  def generate_from_meal_plan
    @meal_plans = current_user.meal_plans.order(:date, :meal_type)

    if request.post?
      selected_ids = params[:meal_plan_ids] || []
      selected_meal_plans = @meal_plans.where(id: selected_ids)
      if recipes.empty?
        @ai_grocery_list = { error: "No meal plans selected. Please select at least one meal plan." }
      else
        @ai_grocery_list = AiRecipeService.generate_grocery_list(recipes, current_user)
        Rails.logger.info("AI Grocery List: #{@ai_grocery_list.inspect}")
      end
    end
  end

  private

  def set_meal_plan
    @meal_plan = current_user.meal_plans.find(params[:id])
  end

  def meal_plan_params
    params.require(:meal_plan).permit(:name, :date, :meal_type, :recipe_id, :notes)
  end

  def authenticate_user!
    redirect_to '/login', alert: 'You need to be logged in to access this page.' unless session[:user_id]
  end
end
