# frozen_string_literal: true

class CreateUserRoles < ActiveRecord::Migration[7.2]
  def change
    create_table :user_roles do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.timestamps
    end

    add_index :user_roles, %i[organization_id user_id role_id], unique: true, name: "idx_tenant_user_roles"
  end
end
