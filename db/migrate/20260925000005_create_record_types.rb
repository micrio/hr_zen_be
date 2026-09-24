# frozen_string_literal: true

class CreateRecordTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :record_types do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.jsonb :field_levels, default: {}, null: false
      t.timestamps
    end

    add_index :record_types, %i[organization_id name], unique: true
  end
end
