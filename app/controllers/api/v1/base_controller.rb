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
      include PlanGated
      include Secured

      before_action :set_paper_trail_whodunnit
      around_action :with_current_tenant

      private

      # Attribute paper_trail versions to the acting user.
      def set_paper_trail_whodunnit
        PaperTrail.request.whodunnit = current_user&.id&.to_s
      end

      # Scope every authenticated request to the user's organization.
      def with_current_tenant(&block)
        organization = current_user&.organization
        return block.call unless organization

        ActsAsTenant.with_tenant(organization, &block)
      end
    end
  end
end
