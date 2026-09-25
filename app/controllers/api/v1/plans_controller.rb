# frozen_string_literal: true

module Api
  module V1
    # Tier catalogue (platform superadmin): which features/limits each plan has.
    class PlansController < BaseController
      # GET /api/v1/plans
      def index
        authorize :organization, :index?, policy_class: OrganizationPolicy

        render_jsonapi(Organization.plan_catalog)
      end
    end
  end
end
