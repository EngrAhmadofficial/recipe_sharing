class PreferencesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
    # Comprehensive categories for enhanced user experience
    @available_categories = [
      'Italian', 'Mexican', 'Asian', 'Mediterranean', 'Indian', 'French', 'American',
      'Vegan', 'Vegetarian', 'Keto', 'Paleo', 'Gluten-Free', 'Dairy-Free', 'Low-Carb',
      'Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Desserts', 'Soups', 'Salads',
      'Quick & Easy', 'Slow Cooker', 'One-Pot', 'Grilling', 'Baking'
    ]
    
    @diet_goals = [
      'Weight Loss', 'Muscle Gain', 'Maintenance', 'Athletic Performance',
      'Heart Health', 'Diabetes Management', 'Digestive Health', 'Energy Boost'
    ]
    
    @cooking_skills = [
      ['Beginner', 'beginner'],
      ['Intermediate', 'intermediate'], 
      ['Advanced', 'advanced']
    ]
    
    @meal_preferences = [
      'Quick Meals (under 30 min)', 'Meal Prep Friendly', 'Family Friendly',
      'Budget Conscious', 'Gourmet', 'Comfort Food', 'Light & Fresh'
    ]
  end

  def update
    @user = current_user
    
    # Extract all preference parameters - handle both array and hash formats
    favorite_categories = if params[:user][:preferences].is_a?(Array)
                           params[:user][:preferences]
                         else
                           params.dig(:user, :preferences, :favoriteCategories) || []
                         end
    
    diet_goals = params.dig(:user, :diet_goals) || []
    allergies = params.dig(:user, :allergies) || []
    cooking_skill = params.dig(:user, :cooking_skill)
    meal_preferences = params.dig(:user, :meal_preferences) || []
    health_conditions = params.dig(:user, :health_conditions) || []
    
    # Update user with all preferences
    if @user.update(
      preferences: { favoriteCategories: favorite_categories },
      diet_goals: diet_goals,
      allergies: allergies,
      cooking_skill: cooking_skill,
      meal_preferences: meal_preferences,
      health_conditions: health_conditions
    )
      redirect_to root_path, notice: "Preferences updated successfully! Your AI recommendations will now be personalized."
    else
      render :edit
    end
  end

  private

  def preferences_params
    params.require(:user).permit(
      preferences: [:favoriteCategories],
      diet_goals: [],
      allergies: [],
      cooking_skill: :string,
      meal_preferences: [],
      health_conditions: []
    )
  end

  def authenticate_user!
    redirect_to '/login', alert: 'You need to be logged in to access this page.' unless session[:user_id]
  end
end
