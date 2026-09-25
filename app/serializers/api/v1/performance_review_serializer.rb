# frozen_string_literal: true

module Api
  module V1
    class PerformanceReviewSerializer < ActiveModel::Serializer
      attributes :id, :user_id, :reviewer_id, :period_start, :period_end,
                 :review_date, :rating, :status, :summary, :strengths,
                 :improvements, :created_at

      attribute :user_name
      attribute :reviewer_name

      def user_name
        object.user&.full_name
      end

      def reviewer_name
        object.reviewer&.full_name
      end

      def rating
        object.rating&.to_f
      end
    end
  end
end
