class AddCategoryToRecipes < ActiveRecord::Migration[7.2]
  def change
    add_column :recipes, :category, :string
  end
end
