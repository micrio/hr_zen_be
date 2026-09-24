# frozen_string_literal: true

module Api
  module V1
    class SessionsController < BaseController
      # Sign in / sign out are public endpoints.
      skip_before_action :authenticate_user!

      # POST /api/v1/sign_in
      def create
        user = Api::V1::SignInService.new(sign_in_params).perform
        token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)

        render_jsonapi(
          {
            user: Api::V1::UserSerializer.new(user).serializable_hash,
            organization: Api::V1::OrganizationSerializer.new(user.organization).serializable_hash,
            token: token
          },
          status: :ok,
          meta: { message: "Signed in successfully." }
        )
      end

      # DELETE /api/v1/sign_out
      def destroy
        # JWT is stateless (Null revocation strategy): the client discards the token.
        render_jsonapi({}, status: :ok, meta: { message: "Signed out successfully." })
      end

      private

      def sign_in_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
