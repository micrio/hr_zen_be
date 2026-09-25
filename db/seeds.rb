# frozen_string_literal: true

# Idempotent seed: the SaaS (platform) superadmin and its home organization.
#
#   bin/rails db:seed
#
# Override with env vars:
#   SUPERADMIN_EMAIL, SUPERADMIN_PASSWORD, PLATFORM_ORG_NAME, PLATFORM_ORG_SUBDOMAIN

superadmin_email = ENV.fetch("SUPERADMIN_EMAIL", "superadmin@hrzen.test")
superadmin_password = ENV.fetch("SUPERADMIN_PASSWORD", "password123")
platform_org_name = ENV.fetch("PLATFORM_ORG_NAME", "HR Zen")
platform_org_subdomain = ENV.fetch("PLATFORM_ORG_SUBDOMAIN", "hr-zen")

organization = Organization.find_or_initialize_by(subdomain: platform_org_subdomain)
organization.name = platform_org_name if organization.name.blank?
organization.plan = "enterprise" if organization.new_record?
organization.save!

# Roles / record types for the platform org.
AuthMatrix::Initializer.setup_workspace!(organization)

user = User.find_by(email: superadmin_email)

if user.nil?
  user = User.new(
    email: superadmin_email,
    first_name: "Platform",
    last_name: "Superadmin",
    organization: organization,
    password: superadmin_password,
    password_confirmation: superadmin_password,
    confirmed_at: Time.current,
    platform_admin: true
  )
  user.skip_confirmation_notification!
  user.save!

  organization.update!(owner: user)

  ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }

  Rails.logger.info("[seed] Created platform superadmin #{user.email}")
  puts "Created platform superadmin: #{user.email} (password: #{superadmin_password})"
else
  user.update!(platform_admin: true)
  user.update!(confirmed_at: Time.current) if user.confirmed_at.nil?
  organization.update!(owner: user) if organization.owner_id.nil?

  ActsAsTenant.with_tenant(organization) do
    user.assign_role("admin") if user.roles.empty?
  end

  Rails.logger.info("[seed] Platform superadmin #{user.email} already present")
  puts "Platform superadmin already present: #{user.email}"
end
