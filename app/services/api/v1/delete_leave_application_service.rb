# frozen_string_literal: true

module Api
  module V1
    class DeleteLeaveApplicationService
      include LeaveBalanceAdjuster

      def initialize(args)
        @application = args[:application]
      end

      def perform
        ActiveRecord::Base.transaction do
          refund_balance!(application) if application.approved?
          application.destroy!
        end
      end

      private

      attr_reader :application
    end
  end
end
