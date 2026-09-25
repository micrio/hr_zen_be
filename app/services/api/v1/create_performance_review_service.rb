# frozen_string_literal: true

module Api
  module V1
    class CreatePerformanceReviewService
      ATTRS = %i[user_id period_start period_end review_date rating status
                 summary strengths improvements].freeze

      def initialize(args)
        @organization = args[:organization]
        @reviewer = args[:reviewer]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        review = PerformanceReview.new(attributes)
        review.organization = organization
        review.reviewer = reviewer
        review.save!
        review
      end

      private

      attr_reader :organization, :reviewer, :attributes
    end
  end
end
