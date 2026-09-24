# frozen_string_literal: true

module Api
  module V1
    class UpdateLeaveTypeService
      ATTRS = %i[name default_days active].freeze

      def initialize(args)
        @leave_type = args[:leave_type]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        leave_type.update!(attributes)
        leave_type
      end

      private

      attr_reader :leave_type, :attributes
    end
  end
end
