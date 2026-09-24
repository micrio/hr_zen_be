# frozen_string_literal: true

class CreateRecordEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :record_entries do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :record_type, null: false, foreign_key: true
      t.string :uuid, null: false
      t.jsonb :data, default: {}, null: false
      t.timestamps
    end

    add_index :record_entries, :uuid, unique: true
    add_index :record_entries, %i[organization_id record_type_id]
  end
end
