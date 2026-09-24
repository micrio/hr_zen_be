# frozen_string_literal: true

module Api
  module V1
    # Creates an Organization and its first (owner) User atomically.
    #
    #   Api::V1::SignUpService.new(organization: {...}, user: {...}).perform
    #   # => User
    class SignUpService
      ORGANIZATION_ATTRS = %i[name email subdomain phone].freeze
      USER_ATTRS = %i[email first_name middle_name last_name password password_confirmation].freeze

      def initialize(args)
        @organization_params = (args[:organization] || {}).to_h.symbolize_keys
        @user_params = (args[:user] || {}).to_h.symbolize_keys
      end

      def perform
        ActiveRecord::Base.transaction do
          organization = build_organization
          organization.save!

          user = build_user(organization)
          user.skip_confirmation_notification!
          user.save!

          organization.update!(owner: user)
          user
        end
      end

      private

      attr_reader :organization_params, :user_params

      def build_organization
        Organization.new(organization_params.slice(*ORGANIZATION_ATTRS))
      end

      def build_user(organization)
        User.new(user_params.slice(*USER_ATTRS)).tap do |user|
          user.organization = organization
        end
      end
    end
  end
end
