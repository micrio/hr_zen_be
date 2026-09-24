# frozen_string_literal: true

module AuthMatrix
  class Initializer
    # Blueprint of default entities and their sensitive attribute tiers.
    REGISTRY = {
      "User" => {
        field_levels: { encrypted_password: 2, reset_password_token: 2 }
      },
      "EmployeeProfile" => {
        field_levels: { salary: 1, bank_account_number: 1, performance_notes: 2 }
      },
      "LeaveApplication" => {
        field_levels: { status: 1, manager_comments: 1 }
      },
      "SalarySlip" => {
        field_levels: { net_pay: 0, status: 1 }
      }
    }.freeze

    # System-wide roles provisioned for each individual workspace.
    DEFAULT_ROLES = %w[superadmin hr_manager leave_approver employee].freeze

    # Builds the full RBAC/ABAC grid for a tenant.
    def self.setup_workspace!(organization)
      raise ArgumentError, "A valid Organization must be provided" if organization.nil?

      Rails.logger.info("[AuthMatrix] Initializing grid for tenant: #{organization.name} (ID: #{organization.id})")

      ActsAsTenant.with_tenant(organization) do
        roles = provision_roles
        record_types = provision_record_types

        apply_tenant_rules(roles, record_types)
        assign_owner_role(organization, roles)
      end

      Rails.logger.info("[AuthMatrix] Grid setup finalized for tenant #{organization.id}")
    end

    def self.provision_roles
      DEFAULT_ROLES.index_with { |role_name| Role.find_or_create_by!(name: role_name) }
    end

    def self.provision_record_types
      REGISTRY.to_h do |name, config|
        record_type = RecordType.find_or_initialize_by(name: name)
        record_type.field_levels = config[:field_levels]
        record_type.save!

        [ name, record_type ]
      end
    end

    def self.assign_owner_role(organization, roles)
      owner = organization.owner
      return if owner.blank?

      owner.user_roles.find_or_create_by!(role: roles["superadmin"])
    end

    def self.apply_tenant_rules(roles, record_types)
      # --- LEAVE APPLICATION INTERSECTIONS ---
      # Employees CRUD their own leave applications (Level 0).
      PermissionRule.find_or_create_by!(
        role: roles["employee"],
        record_type: record_types["LeaveApplication"],
        perm_level: 0
      ) do |p|
        p.can_read = true
        p.can_create = true
        p.can_write = true
        p.apply_user_permissions = true
      end

      # Employees view but cannot touch Level 1 status fields.
      PermissionRule.find_or_create_by!(
        role: roles["employee"],
        record_type: record_types["LeaveApplication"],
        perm_level: 1
      ) do |p|
        p.can_read = true
        p.can_write = false
      end

      # Leave approvers can read and alter Level 1 status flags.
      PermissionRule.find_or_create_by!(
        role: roles["leave_approver"],
        record_type: record_types["LeaveApplication"],
        perm_level: 1
      ) do |p|
        p.can_read = true
        p.can_write = true
      end

      # --- EMPLOYEE PROFILE INTERSECTIONS ---
      # HR managers manage base employee structural items company-wide.
      PermissionRule.find_or_create_by!(
        role: roles["hr_manager"],
        record_type: record_types["EmployeeProfile"],
        perm_level: 0
      ) do |p|
        p.can_read = true
        p.can_write = true
        p.can_create = true
        p.can_delete = false
        p.apply_user_permissions = false
      end

      # HR managers may write high-security financial tiers (Level 1).
      PermissionRule.find_or_create_by!(
        role: roles["hr_manager"],
        record_type: record_types["EmployeeProfile"],
        perm_level: 1
      ) do |p|
        p.can_read = true
        p.can_write = true
      end
    end

    private_class_method :provision_roles, :provision_record_types, :assign_owner_role, :apply_tenant_rules
  end
end
