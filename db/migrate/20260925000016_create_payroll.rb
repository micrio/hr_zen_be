# frozen_string_literal: true

class CreatePayroll < ActiveRecord::Migration[7.2]
  def change
    create_table :payroll_settings do |t|
      t.references :organization, null: false, foreign_key: true, index: { unique: true }
      t.string :currency, default: "USD", null: false
      t.string :default_salary_type, default: "daily", null: false
      t.timestamps
    end

    create_table :compensations do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :salary_type, default: "daily", null: false
      t.decimal :rate, precision: 12, scale: 2, default: 0, null: false
      t.timestamps
    end
    add_index :compensations, %i[organization_id user_id], unique: true

    create_table :payroll_entries do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.string :salary_type, null: false
      t.decimal :rate, precision: 12, scale: 2, default: 0, null: false
      t.decimal :units, precision: 10, scale: 2, default: 0, null: false
      t.decimal :gross_amount, precision: 12, scale: 2, default: 0, null: false
      t.decimal :net_amount, precision: 12, scale: 2, default: 0, null: false
      t.jsonb :adjustments, default: [], null: false
      t.string :currency, default: "USD", null: false
      t.datetime :computed_at
      t.timestamps
    end
    add_index :payroll_entries, %i[organization_id user_id period_start]
  end
end
