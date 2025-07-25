class AddAiFieldsToMealPlans < ActiveRecord::Migration[7.0]
  def change
    add_column :meal_plans, :calories, :integer
    add_column :meal_plans, :protein, :integer
    add_column :meal_plans, :carbs, :integer
    add_column :meal_plans, :fats, :integer
    add_column :meal_plans, :ingredients, :text
    add_column :meal_plans, :instructions, :text
  end
end 