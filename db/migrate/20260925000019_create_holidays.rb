# frozen_string_literal: true

class CreateHolidays < ActiveRecord::Migration[7.2]
  def change
    create_table :holidays do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.date :date, null: false
      t.boolean :recurring, default: false, null: false
      t.timestamps
    end

    add_index :holidays, %i[organization_id date], unique: true
  end
end
