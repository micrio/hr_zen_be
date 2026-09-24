# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      # GET /api/v1/users/me
      # Returns the currently authenticated user (JWT bearer token).
      def me
        render_jsonapi(
          {
            user: Api::V1::UserSerializer.new(current_user).serializable_hash,
            organization: Api::V1::OrganizationSerializer.new(current_user.organization).serializable_hash
          },
          status: :ok
        )
      end
    end
  end
end
