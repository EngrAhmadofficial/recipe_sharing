class CreateMealPlans < ActiveRecord::Migration[7.2]
  def change
    create_table :meal_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.date :date
      t.string :meal_type
      t.references :recipe, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end
