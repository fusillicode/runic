class CreateRunes < ActiveRecord::Migration
  def change
    create_table :runes do |t|
      t.string :name, null: false
      t.string :description
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
