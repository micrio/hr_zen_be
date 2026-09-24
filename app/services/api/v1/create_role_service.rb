# frozen_string_literal: true

module Api
  module V1
    class CreateRoleService
      def initialize(args)
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(:name)
      end

      def perform
        Role.create!(attributes)
      end

      private

      attr_reader :attributes
    end
  end
end
