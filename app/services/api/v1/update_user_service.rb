# frozen_string_literal: true

module Api
  module V1
    class UpdateUserService
      ATTRS = %i[email first_name middle_name last_name password password_confirmation].freeze

      def initialize(args)
        @user = args[:user]
        @attributes = clean_attributes(args[:attributes])
        @role_names = args.key?(:role_names) ? normalize_roles(args[:role_names]) : nil
      end

      def perform
        ActiveRecord::Base.transaction do
          user.update!(attributes)
          replace_roles if role_names
          user
        end
      end

      private

      attr_reader :user, :attributes, :role_names

      def clean_attributes(value)
        attrs = (value || {}).to_h.symbolize_keys.slice(*ATTRS)
        # Blank password means "leave unchanged".
        attrs.delete(:password) if attrs[:password].blank?
        attrs.delete(:password_confirmation) if attrs[:password_confirmation].blank?
        attrs
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
