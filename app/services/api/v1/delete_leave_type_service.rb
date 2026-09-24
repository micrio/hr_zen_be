# frozen_string_literal: true

module Api
  module V1
    class DeleteLeaveTypeService
      def initialize(args)
        @leave_type = args[:leave_type]
      end

      def perform
        if leave_type.leave_balances.exists? || leave_type.leave_applications.exists?
          raise Api::Error::UnprocessableEntity.new(
            "Leave type cannot be deleted",
            details: { base: [ "Remove its balances and applications first." ] }
          )
        end

        leave_type.destroy!
      end

      private

      attr_reader :leave_type
    end
  end
end
