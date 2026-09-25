# frozen_string_literal: true

module Api
  module V1
    class DeletePerformanceReviewService
      def initialize(args)
        @review = args[:review]
      end

      def perform
        review.destroy!
      end

      private

      attr_reader :review
    end
  end
end
