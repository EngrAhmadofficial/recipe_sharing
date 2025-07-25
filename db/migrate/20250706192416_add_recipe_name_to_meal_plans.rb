class AddRecipeNameToMealPlans < ActiveRecord::Migration[7.2]
  def change
    add_column :meal_plans, :recipe_name, :string
  end
end
