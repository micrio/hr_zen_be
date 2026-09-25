# frozen_string_literal: true

module Api
  module V1
    class UpdatePerformanceReviewService
      ATTRS = %i[period_start period_end review_date rating status summary
                 strengths improvements].freeze

      def initialize(args)
        @review = args[:review]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        review.update!(attributes)
        review
      end

      private

      attr_reader :review, :attributes
    end
  end
end
