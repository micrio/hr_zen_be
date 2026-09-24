# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_09_25_000010) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "recordable_type"
    t.bigint "recordable_id"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country"
    t.boolean "primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_addresses_on_organization_id"
    t.index ["recordable_type", "recordable_id"], name: "index_addresses_on_recordable"
  end

  create_table "organizations", force: :cascade do |t|
    t.bigint "owner_id"
    t.string "name"
    t.string "uuid"
    t.string "email"
    t.string "phone"
    t.string "subdomain"
    t.datetime "established_at"
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_organizations_on_owner_id"
    t.index ["subdomain"], name: "index_organizations_on_subdomain", unique: true
    t.index ["uuid"], name: "index_organizations_on_uuid", unique: true
  end

  create_table "permission_rules", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "role_id", null: false
    t.bigint "record_type_id", null: false
    t.integer "perm_level", default: 0, null: false
    t.boolean "can_read", default: false, null: false
    t.boolean "can_write", default: false, null: false
    t.boolean "can_create", default: false, null: false
    t.boolean "can_delete", default: false, null: false
    t.boolean "can_submit", default: false, null: false
    t.boolean "can_cancel", default: false, null: false
    t.boolean "can_amend", default: false, null: false
    t.boolean "can_export", default: false, null: false
    t.boolean "can_print", default: false, null: false
    t.boolean "apply_user_permissions", default: false, null: false
    t.boolean "can_set_user_permissions", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "role_id", "record_type_id", "perm_level"], name: "idx_auth_matrix_tenant_lookup", unique: true
    t.index ["organization_id"], name: "index_permission_rules_on_organization_id"
    t.index ["record_type_id"], name: "index_permission_rules_on_record_type_id"
    t.index ["role_id"], name: "index_permission_rules_on_role_id"
  end

  create_table "record_entries", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "record_type_id", null: false
    t.string "uuid", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "record_type_id"], name: "index_record_entries_on_organization_id_and_record_type_id"
    t.index ["organization_id"], name: "index_record_entries_on_organization_id"
    t.index ["record_type_id"], name: "index_record_entries_on_record_type_id"
    t.index ["uuid"], name: "index_record_entries_on_uuid", unique: true
  end

  create_table "record_types", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "fields", default: [], null: false
    t.index ["organization_id", "name"], name: "index_record_types_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_record_types_on_organization_id"
  end

  create_table "roles", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_roles_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_roles_on_organization_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "user_id", "role_id"], name: "idx_tenant_user_roles", unique: true
    t.index ["organization_id"], name: "index_user_roles_on_organization_id"
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uuid", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uuid", "provider"], name: "index_users_on_uuid_and_provider", unique: true
  end

  add_foreign_key "addresses", "organizations"
  add_foreign_key "organizations", "users", column: "owner_id"
  add_foreign_key "permission_rules", "organizations"
  add_foreign_key "permission_rules", "record_types"
  add_foreign_key "permission_rules", "roles"
  add_foreign_key "record_entries", "organizations"
  add_foreign_key "record_entries", "record_types"
  add_foreign_key "record_types", "organizations"
  add_foreign_key "roles", "organizations"
  add_foreign_key "user_roles", "organizations"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "organizations"
end
