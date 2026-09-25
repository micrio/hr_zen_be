# frozen_string_literal: true

module Api
  module V1
    class ListPerformanceReviewsService
      def initialize(args = {})
        @user_id = args[:user_id].presence
        @status = args[:status].presence
      end

      def perform
        scope = PerformanceReview.includes(:user, :reviewer).recent_first
        scope = scope.where(user_id: user_id) if user_id
        scope = scope.where(status: status) if status
        scope
      end

      private

      attr_reader :user_id, :status
    end
  end
end
