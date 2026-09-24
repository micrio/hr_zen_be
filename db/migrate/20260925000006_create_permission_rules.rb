# frozen_string_literal: true

class CreatePermissionRules < ActiveRecord::Migration[7.2]
  def change
    create_table :permission_rules do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.references :record_type, null: false, foreign_key: true
      t.integer :perm_level, default: 0, null: false
      t.boolean :can_read, default: false, null: false
      t.boolean :can_write, default: false, null: false
      t.boolean :can_create, default: false, null: false
      t.boolean :can_delete, default: false, null: false
      t.boolean :can_submit, default: false, null: false
      t.boolean :can_cancel, default: false, null: false
      t.boolean :can_amend, default: false, null: false
      t.boolean :can_export, default: false, null: false
      t.boolean :can_print, default: false, null: false
      t.boolean :apply_user_permissions, default: false, null: false
      t.boolean :can_set_user_permissions, default: false, null: false
      t.timestamps
    end

    add_index :permission_rules,
              %i[organization_id role_id record_type_id perm_level],
              unique: true,
              name: "idx_auth_matrix_tenant_lookup"
  end
end
