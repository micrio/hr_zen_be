# frozen_string_literal: true

module Api
  module V1
    class CreatePermissionRuleService
      ATTS = %i[role_id record_type_id perm_level].freeze

      def initialize(args)
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTS)
        @actions = PermissionRuleActions.extract(args[:attributes])
      end

      def perform
        PermissionRule.create!(attributes.merge(actions))
      end

      private

      attr_reader :attributes, :actions
    end
  end
end
