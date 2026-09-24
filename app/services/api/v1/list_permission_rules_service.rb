# frozen_string_literal: true

module Api
  module V1
    class ListPermissionRulesService
      def initialize(args = {})
        @role_id = args[:role_id].presence
        @record_type_id = args[:record_type_id].presence
      end

      def perform
        scope = PermissionRule.includes(:role, :record_type).order(:perm_level)
        scope = scope.where(role_id: role_id) if role_id
        scope = scope.where(record_type_id: record_type_id) if record_type_id
        scope
      end

      private

      attr_reader :role_id, :record_type_id
    end
  end
end
