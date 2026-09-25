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

ActiveRecord::Schema[7.2].define(version: 2026_09_25_000016) do
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

  create_table "attendance_events", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.string "kind", null: false
    t.datetime "occurred_at", null: false
    t.float "distance"
    t.string "source", default: "face"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "user_id", "occurred_at"], name: "idx_on_organization_id_user_id_occurred_at_172a839e0f"
    t.index ["organization_id"], name: "index_attendance_events_on_organization_id"
    t.index ["user_id"], name: "index_attendance_events_on_user_id"
  end

  create_table "attendance_settings", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.boolean "enabled", default: false, null: false
    t.string "clock_token", null: false
    t.integer "cooldown_seconds", default: 60, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clock_token"], name: "index_attendance_settings_on_clock_token", unique: true
    t.index ["organization_id"], name: "index_attendance_settings_on_organization_id", unique: true
  end

  create_table "compensations", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.string "salary_type", default: "daily", null: false
    t.decimal "rate", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "user_id"], name: "index_compensations_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_compensations_on_organization_id"
    t.index ["user_id"], name: "index_compensations_on_user_id"
  end

  create_table "face_embeddings", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.jsonb "vector", default: [], null: false
    t.integer "dimension", default: 0, null: false
    t.string "source", default: "camera"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "user_id"], name: "index_face_embeddings_on_organization_id_and_user_id"
    t.index ["organization_id"], name: "index_face_embeddings_on_organization_id"
    t.index ["user_id"], name: "index_face_embeddings_on_user_id"
  end

  create_table "leave_applications", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.bigint "leave_type_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.decimal "days", precision: 6, scale: 2, null: false
    t.string "status", default: "pending", null: false
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["leave_type_id"], name: "index_leave_applications_on_leave_type_id"
    t.index ["organization_id", "user_id", "start_date"], name: "idx_on_organization_id_user_id_start_date_e1e9416be5"
    t.index ["organization_id"], name: "index_leave_applications_on_organization_id"
    t.index ["user_id"], name: "index_leave_applications_on_user_id"
  end

  create_table "leave_balances", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.bigint "leave_type_id", null: false
    t.decimal "entitled_days", precision: 6, scale: 2, default: "0.0", null: false
    t.decimal "used_days", precision: 6, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["leave_type_id"], name: "index_leave_balances_on_leave_type_id"
    t.index ["organization_id", "user_id", "leave_type_id"], name: "idx_leave_balances_unique", unique: true
    t.index ["organization_id"], name: "index_leave_balances_on_organization_id"
    t.index ["user_id"], name: "index_leave_balances_on_user_id"
  end

  create_table "leave_types", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.decimal "default_days", precision: 6, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_leave_types_on_organization_id_and_name", unique: true
    t.index ["organization_id"], name: "index_leave_types_on_organization_id"
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

  create_table "payroll_entries", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.date "period_start", null: false
    t.date "period_end", null: false
    t.string "salary_type", null: false
    t.decimal "rate", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "units", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "gross_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "net_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.jsonb "adjustments", default: [], null: false
    t.string "currency", default: "USD", null: false
    t.datetime "computed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "user_id", "period_start"], name: "idx_on_organization_id_user_id_period_start_955b186977"
    t.index ["organization_id"], name: "index_payroll_entries_on_organization_id"
    t.index ["user_id"], name: "index_payroll_entries_on_user_id"
  end

  create_table "payroll_settings", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "currency", default: "USD", null: false
    t.string "default_salary_type", default: "daily", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_payroll_settings_on_organization_id", unique: true
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
    t.jsonb "custom_fields", default: {}, null: false
    t.integer "age"
    t.string "gender"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uuid", "provider"], name: "index_users_on_uuid_and_provider", unique: true
  end

  add_foreign_key "addresses", "organizations"
  add_foreign_key "attendance_events", "organizations"
  add_foreign_key "attendance_events", "users"
  add_foreign_key "attendance_settings", "organizations"
  add_foreign_key "compensations", "organizations"
  add_foreign_key "compensations", "users"
  add_foreign_key "face_embeddings", "organizations"
  add_foreign_key "face_embeddings", "users"
  add_foreign_key "leave_applications", "leave_types"
  add_foreign_key "leave_applications", "organizations"
  add_foreign_key "leave_applications", "users"
  add_foreign_key "leave_balances", "leave_types"
  add_foreign_key "leave_balances", "organizations"
  add_foreign_key "leave_balances", "users"
  add_foreign_key "leave_types", "organizations"
  add_foreign_key "organizations", "users", column: "owner_id"
  add_foreign_key "payroll_entries", "organizations"
  add_foreign_key "payroll_entries", "users"
  add_foreign_key "payroll_settings", "organizations"
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
