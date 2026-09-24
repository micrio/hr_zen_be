# frozen_string_literal: true

module Api
  module V1
    # Shared helper to extract the boolean action flags from raw params.
    module PermissionRuleActions
      def self.extract(raw)
        source = (raw || {}).to_h.symbolize_keys

        PermissionRule::ACTIONS.each_with_object({}) do |action, memo|
          next unless source.key?(action)

          memo[action] = ActiveModel::Type::Boolean.new.cast(source[action])
        end
      end
    end
  end
end
