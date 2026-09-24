# frozen_string_literal: true

module Api
  module V1
    class UpdateLeaveApplicationService
      include LeaveBalanceAdjuster

      ATTRS = %i[user_id leave_type_id start_date end_date days status reason].freeze

      def initialize(args)
        @application = args[:application]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        ActiveRecord::Base.transaction do
          application.reload

          refund_balance!(application) if application.approved?
          application.assign_attributes(attributes)
          application.save!
          deduct_balance!(application) if application.approved?

          application
        end
      end

      private

      attr_reader :application, :attributes
    end
  end
end
