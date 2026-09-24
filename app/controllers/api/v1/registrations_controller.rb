# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < BaseController
      # Public endpoint: no authentication required.
      skip_before_action :authenticate_user!

      ORGANIZATION_ATTRS = Api::V1::SignUpService::ORGANIZATION_ATTRS
      USER_ATTRS = Api::V1::SignUpService::USER_ATTRS

      # POST /api/v1/sign_up
      def create
        user = Api::V1::SignUpService.new(sign_up_params).perform

        SetupWorkspaceJob.perform_later(user.organization_id)

        render_jsonapi(
          {
            organization: Api::V1::OrganizationSerializer.new(user.organization).serializable_hash,
            user: Api::V1::UserSerializer.new(user).serializable_hash
          },
          status: :created,
          meta: { message: "Workspace created successfully." }
        )
      end

      private

      def sign_up_params
        params.require(:organization)
        params.require(:user)

        params.permit(organization: ORGANIZATION_ATTRS, user: USER_ATTRS).to_h.symbolize_keys
      end
    end
  end
end
