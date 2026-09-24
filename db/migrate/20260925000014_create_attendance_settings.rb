# frozen_string_literal: true

class CreateAttendanceSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :attendance_settings do |t|
      t.references :organization, null: false, foreign_key: true, index: { unique: true }
      t.boolean :enabled, default: false, null: false
      t.string :clock_token, null: false
      t.integer :cooldown_seconds, default: 60, null: false
      t.timestamps
    end

    add_index :attendance_settings, :clock_token, unique: true
  end
end
