# frozen_string_literal: true

module Api
  module V1
    # Force-confirms a user's email (superadmin action). Idempotent.
    class ConfirmUserService
      def initialize(args)
        @user = args[:user]
      end

      def perform
        return user if user.confirmed?

        user.update!(
          confirmed_at: Time.current,
          confirmation_token: nil,
          unconfirmed_email: nil
        )
        user
      end

      private

      attr_reader :user
    end
  end
end
