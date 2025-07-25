class MealPlan < ApplicationRecord
  belongs_to :user
  belongs_to :recipe, optional: true
  
  # Validations
  validates :name, presence: true
  validates :date, presence: true
  validates :meal_type, inclusion: { in: %w[breakfast lunch dinner snack] }
  
  # Scopes
  scope :for_date, ->(date) { where(date: date) }
  scope :for_week, ->(start_date) { where(date: start_date..start_date + 6.days) }
  scope :by_meal_type, ->(meal_type) { where(meal_type: meal_type) }
  
  # Instance methods
  def self.generate_grocery_list(user, start_date, end_date)
    meal_plans = user.meal_plans.where(date: start_date..end_date).includes(:recipe)
    ingredients = []
    
    meal_plans.each do |meal_plan|
      next unless meal_plan.recipe&.ingredients
      
      recipe_ingredients = meal_plan.recipe.ingredients.split(',').map(&:strip)
      ingredients.concat(recipe_ingredients)
    end
    
    ingredients.uniq
  end
end
