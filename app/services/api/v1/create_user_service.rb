# frozen_string_literal: true

module Api
  module V1
    class CreateUserService
      ATTRS = %i[email first_name middle_name last_name age gender password password_confirmation].freeze

      def initialize(args)
        @organization = args[:organization]
        @attributes = (args[:user] || {}).to_h.symbolize_keys.slice(*ATTRS)
        @role_names = normalize_roles(args[:role_names])
        @custom_fields = args[:custom_fields]
      end

      def perform
        ActiveRecord::Base.transaction do
          user = build_user
          user.custom_fields = normalized_custom_fields
          user.save!
          assign_roles(user)
          user
        end
      end

      private

      attr_reader :organization, :attributes, :role_names, :custom_fields

      def build_user
        User.new(attributes).tap do |user|
          user.organization = organization
          user.skip_confirmation_notification!
        end
      end

      def normalized_custom_fields
        return {} if custom_fields.blank?

        ActsAsTenant.with_tenant(organization) do
          Api::V1::UserCustomFields.validate!(custom_fields)
        end
      end

      def assign_roles(user)
        return if role_names.empty?

        ActsAsTenant.with_tenant(organization) do
          role_names.each do |name|
            user.user_roles.find_or_create_by!(role: Role.find_by!(name: name))
          end
        end
      end

      def normalize_roles(value)
        Array(value).map { |name| name.to_s.downcase.strip }.reject(&:blank?).uniq
      end
    end
  end
end
