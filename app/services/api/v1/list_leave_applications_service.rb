# frozen_string_literal: true

module Api
  module V1
    class ListLeaveApplicationsService
      def initialize(args = {})
        @user_id = args[:user_id].presence
        @leave_type_id = args[:leave_type_id].presence
        @status = args[:status].presence
      end

      def perform
        scope = LeaveApplication.includes(:user, :leave_type).recent_first
        scope = scope.where(user_id: user_id) if user_id
        scope = scope.where(leave_type_id: leave_type_id) if leave_type_id
        scope = scope.where(status: status) if status
        scope
      end

      private

      attr_reader :user_id, :leave_type_id, :status
    end
  end
end
