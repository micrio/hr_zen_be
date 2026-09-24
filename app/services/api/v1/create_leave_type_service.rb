# frozen_string_literal: true

module Api
  module V1
    class CreateLeaveTypeService
      ATTRS = %i[name default_days active].freeze

      def initialize(args)
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        LeaveType.create!(attributes)
      end

      private

      attr_reader :attributes
    end
  end
end
