# frozen_string_literal: true

module Api
  module V1
    class ListPayrollEntriesService
      def initialize(args = {})
        @user_id = args[:user_id].presence
      end

      def perform
        scope = PayrollEntry.includes(:user).recent_first
        scope = scope.where(user_id: user_id) if user_id
        scope
      end

      private

      attr_reader :user_id
    end
  end
end
