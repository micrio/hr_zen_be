# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < BaseController
      before_action :set_organization, only: %i[update]

      # GET /api/v1/organizations  (platform superadmin)
      def index
        authorize Organization

        organizations = Organization.includes(:users).order(:created_at)

        render_jsonapi(
          organizations.map do |organization|
            Api::V1::AdminOrganizationSerializer.new(organization).serializable_hash
          end
        )
      end

      # PATCH /api/v1/organizations/:id  (platform superadmin)
      def update
        authorize @organization

        @organization.update!(organization_params)

        render_jsonapi(
          Api::V1::AdminOrganizationSerializer.new(@organization).serializable_hash,
          meta: { message: "Organization updated successfully." }
        )
      end

      private

      def set_organization
        @organization = Organization.find(params[:id])
      end

      def organization_params
        params.require(:organization).permit(:name, :subdomain, :plan, :status)
      end
    end
  end
end
