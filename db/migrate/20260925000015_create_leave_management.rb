# frozen_string_literal: true

class CreateLeaveManagement < ActiveRecord::Migration[7.2]
  def change
    create_table :leave_types do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :default_days, precision: 6, scale: 2, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end
    add_index :leave_types, %i[organization_id name], unique: true

    create_table :leave_balances do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :leave_type, null: false, foreign_key: true
      t.decimal :entitled_days, precision: 6, scale: 2, default: 0, null: false
      t.decimal :used_days, precision: 6, scale: 2, default: 0, null: false
      t.timestamps
    end
    add_index :leave_balances, %i[organization_id user_id leave_type_id],
              unique: true,
              name: "idx_leave_balances_unique"

    create_table :leave_applications do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :leave_type, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.decimal :days, precision: 6, scale: 2, null: false
      t.string :status, default: "pending", null: false
      t.text :reason
      t.timestamps
    end
    add_index :leave_applications, %i[organization_id user_id start_date]
  end
end
