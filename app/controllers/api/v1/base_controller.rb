# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      # Clients always send the fully-shaped payload; don't wrap under the controller name.
      wrap_parameters false

      include Devise::Controllers::Helpers
      include Pundit::Authorization
      include JsonRenderer
      include RescueExceptions
      include Secured

      around_action :with_current_tenant

      private

      # Scope every authenticated request to the user's organization.
      def with_current_tenant(&block)
        organization = current_user&.organization
        return block.call unless organization

        ActsAsTenant.with_tenant(organization, &block)
      end
    end
  end
end
