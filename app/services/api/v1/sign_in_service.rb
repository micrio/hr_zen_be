# frozen_string_literal: true

module Api
  module V1
    # Authenticates an existing user by email + password.
    #
    #   Api::V1::SignInService.new(email: "...", password: "...").perform
    #   # => User
    class SignInService
      def initialize(args)
        @email = args[:email].to_s.strip.downcase
        @password = args[:password].to_s
      end

      def perform
        user = User.find_for_database_authentication(email: email)

        raise Api::Error::UnauthorizedError, "Invalid email or password" if user.blank?
        raise Api::Error::UnauthorizedError, "Invalid email or password" unless user.valid_password?(password)

        user
      end

      private

      attr_reader :email, :password
    end
  end
end
