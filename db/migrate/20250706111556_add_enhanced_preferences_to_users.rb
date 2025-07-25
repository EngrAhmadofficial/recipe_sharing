class AddEnhancedPreferencesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :diet_goals, :json
    add_column :users, :allergies, :json
    add_column :users, :cooking_skill, :string
    add_column :users, :meal_preferences, :json
    add_column :users, :health_conditions, :json
  end
end
