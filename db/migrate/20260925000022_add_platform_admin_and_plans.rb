# frozen_string_literal: true

class AddPlatformAdminAndPlans < ActiveRecord::Migration[7.2]
  def up
    add_column :users, :platform_admin, :boolean, default: false, null: false
    add_column :organizations, :plan, :string, default: "free", null: false

    rename_superadmin_roles!
    flag_seed_user!
  end

  def down
    remove_column :users, :platform_admin
    remove_column :organizations, :plan
  end

  private

  # Org-level `superadmin` becomes `admin` (merging if an `admin` role exists).
  def rename_superadmin_roles!
    Organization.find_each do |org|
      ActsAsTenant.with_tenant(org) do
        legacy = Role.find_by(name: "superadmin")
        next if legacy.nil?

        admin = Role.find_or_create_by!(name: "admin")

        legacy.user_roles.find_each do |user_role|
          if admin.user_roles.exists?(user_id: user_role.user_id)
            user_role.destroy!
          else
            user_role.update!(role_id: admin.id)
          end
        end

        legacy.permission_rules.find_each do |rule|
          duplicate = admin.permission_rules.find_by(
            record_type_id: rule.record_type_id,
            perm_level: rule.perm_level
          )
          duplicate ? rule.destroy! : rule.update!(role_id: admin.id)
        end

        legacy.destroy!
      end
    end
  end

  # The seeded first user is the SaaS (platform) superadmin.
  def flag_seed_user!
    User.order(:created_at).first&.update_columns(platform_admin: true)
  end
end
