# frozen_string_literal: true

ActsAsTenant.configure do |config|
  # Controllers/jobs must explicitly wrap tenant work in ActsAsTenant.with_tenant.
  config.require_tenant = false
end
