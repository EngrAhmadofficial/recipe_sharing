class AddNutritionalInfoToRecipes < ActiveRecord::Migration[7.2]
  def change
    add_column :recipes, :calories, :integer
    add_column :recipes, :protein, :decimal
    add_column :recipes, :carbs, :decimal
    add_column :recipes, :fats, :decimal
    add_column :recipes, :fiber, :decimal
    add_column :recipes, :sugar, :decimal
    add_column :recipes, :sodium, :integer
  end
end
