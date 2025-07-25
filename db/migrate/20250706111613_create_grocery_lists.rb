class CreateGroceryLists < ActiveRecord::Migration[7.2]
  def change
    create_table :grocery_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.json :items
      t.boolean :completed

      t.timestamps
    end
  end
end
