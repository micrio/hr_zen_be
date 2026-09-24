# frozen_string_literal: true

module Api
  module V1
    class UpdateUserService
      ATTRS = %i[email first_name middle_name last_name age gender password password_confirmation].freeze

      def initialize(args)
        @user = args[:user]
        @attributes = clean_attributes(args[:attributes])
        @role_names = args.key?(:role_names) ? normalize_roles(args[:role_names]) : nil
        @custom_fields = args.key?(:custom_fields) ? args[:custom_fields] : nil
      end

      def perform
        ActiveRecord::Base.transaction do
          user.update!(attributes)
          update_custom_fields unless custom_fields.nil?
          replace_roles if role_names
          user
        end
      end

      private

      attr_reader :user, :attributes, :role_names, :custom_fields

      def clean_attributes(value)
        attrs = (value || {}).to_h.symbolize_keys.slice(*ATTRS)
        attrs.delete(:password) if attrs[:password].blank?
        attrs.delete(:password_confirmation) if attrs[:password_confirmation].blank?
        attrs
      end

      def update_custom_fields
        ActsAsTenant.with_tenant(user.organization) do
          merged = user.custom_fields.to_h.merge((custom_fields || {}).to_h.stringify_keys)
          user.update!(custom_fields: Api::V1::UserCustomFields.validate!(merged))
        end
      end

      def replace_roles
        ActsAsTenant.with_tenant(user.organization) do
          user.user_roles.destroy_all
          role_names.each do |name|
            user.user_roles.create!(role: Role.find_by!(name: name))
          end
        end
      end

      def normalize_roles(value)
        Array(value).map { |name| name.to_s.downcase.strip }.reject(&:blank?).uniq
      end
    end
  end
end
