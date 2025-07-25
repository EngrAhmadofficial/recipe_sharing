class CreateUserRecipes < ActiveRecord::Migration[7.2]
  def change
    create_table :user_recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.integer :rating
      t.text :review
      t.boolean :favorite

      t.timestamps
    end
  end
end
