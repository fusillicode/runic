class CreatePowers < ActiveRecord::Migration
  def change
    create_table :powers do |t|
      t.string :name
      t.string :description
      t.references :rune, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
