# frozen_string_literal: true

module Api
  module V1
    class UpdatePermissionRuleService
      ATTS = %i[role_id record_type_id perm_level].freeze

      def initialize(args)
        @permission_rule = args[:permission_rule]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTS)
        @actions = PermissionRuleActions.extract(args[:attributes])
      end

      def perform
        permission_rule.update!(attributes.merge(actions))
        permission_rule
      end

      private

      attr_reader :permission_rule, :attributes, :actions
    end
  end
end
