# frozen_string_literal: true

module Api
  module V1
    class DeleteRoleService
      PROTECTED_ROLES = %w[admin superadmin].freeze

      def initialize(args)
        @role = args[:role]
      end

      def perform
        guard_protected!
        guard_assigned!

        role.destroy!
      end

      private

      attr_reader :role

      def guard_protected!
        return unless PROTECTED_ROLES.include?(role.name)

        raise Api::Error::UnprocessableEntity.new(
          "Role cannot be deleted",
          details: { base: [ "#{role.name} is a system role." ] }
        )
      end

      def guard_assigned!
        return unless role.user_roles.exists?

        raise Api::Error::UnprocessableEntity.new(
          "Role cannot be deleted",
          details: { base: [ "Remove the role from all users first." ] }
        )
      end
    end
  end
end
