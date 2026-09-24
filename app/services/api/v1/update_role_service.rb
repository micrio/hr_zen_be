# frozen_string_literal: true

module Api
  module V1
    class UpdateRoleService
      def initialize(args)
        @role = args[:role]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(:name)
      end

      def perform
        role.update!(attributes)
        role
      end

      private

      attr_reader :role, :attributes
    end
  end
end
