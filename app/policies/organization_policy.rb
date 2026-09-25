# frozen_string_literal: true

# SaaS-level: only the platform superadmin manages organizations.
class OrganizationPolicy < ApplicationPolicy
  def index?
    platform_admin?
  end

  def update?
    platform_admin?
  end

  private

  def platform_admin?
    user&.platform_admin? == true
  end
end
