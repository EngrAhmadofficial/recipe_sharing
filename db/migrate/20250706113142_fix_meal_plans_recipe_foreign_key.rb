class FixMealPlansRecipeForeignKey < ActiveRecord::Migration[7.2]
  def change
    # Remove the null constraint from recipe_id
    change_column_null :meal_plans, :recipe_id, true
    
    # Remove the foreign key constraint temporarily
    remove_foreign_key :meal_plans, :recipes
    
    # Add the foreign key constraint back with proper options
    add_foreign_key :meal_plans, :recipes, on_delete: :nullify
  end
end
