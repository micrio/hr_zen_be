# frozen_string_literal: true

module Api
  module V1
    class DeletePermissionRuleService
      def initialize(args)
        @permission_rule = args[:permission_rule]
      end

      def perform
        permission_rule.destroy!
      end

      private

      attr_reader :permission_rule
    end
  end
end
