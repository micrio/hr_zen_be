# frozen_string_literal: true

module Api
  module V1
    class CreateLeaveApplicationService
      include LeaveBalanceAdjuster

      ATTRS = %i[user_id leave_type_id start_date end_date days status reason].freeze

      def initialize(args)
        @organization = args[:organization]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        ActiveRecord::Base.transaction do
          application = LeaveApplication.new(attributes)
          application.organization = organization
          application.save!

          deduct_balance!(application) if application.approved?
          application
        end
      end

      private

      attr_reader :organization, :attributes
    end
  end
end
