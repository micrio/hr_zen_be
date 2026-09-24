# frozen_string_literal: true

module Api
  module V1
    class ListLeaveBalancesService
      def initialize(args = {})
        @user_id = args[:user_id].presence
        @leave_type_id = args[:leave_type_id].presence
      end

      def perform
        scope = LeaveBalance.includes(:user, :leave_type)
                            .joins(:user)
                            .order("users.first_name ASC, users.last_name ASC")
        scope = scope.where(user_id: user_id) if user_id
        scope = scope.where(leave_type_id: leave_type_id) if leave_type_id
        scope
      end

      private

      attr_reader :user_id, :leave_type_id
    end
  end
end
