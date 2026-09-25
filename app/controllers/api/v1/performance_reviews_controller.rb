# frozen_string_literal: true

module Api
  module V1
    class PerformanceReviewsController < BaseController
      plan_feature :performance

      before_action :set_review, only: %i[update destroy]

      # GET /api/v1/performance_reviews?user_id=
      def index
        authorize PerformanceReview

        reviews = Api::V1::ListPerformanceReviewsService.new(
          user_id: params[:user_id],
          status: params[:status]
        ).perform

        render_jsonapi(
          reviews.map do |review|
            Api::V1::PerformanceReviewSerializer.new(review).serializable_hash
          end
        )
      end

      # POST /api/v1/performance_reviews
      def create
        authorize PerformanceReview

        review = Api::V1::CreatePerformanceReviewService.new(
          organization: current_user.organization,
          reviewer: current_user,
          attributes: review_params
        ).perform

        render_jsonapi(
          Api::V1::PerformanceReviewSerializer.new(review).serializable_hash,
          status: :created,
          meta: { message: "Performance review created successfully." }
        )
      end

      # PATCH /api/v1/performance_reviews/:id
      def update
        authorize @review

        review = Api::V1::UpdatePerformanceReviewService.new(
          review: @review,
          attributes: review_params
        ).perform

        render_jsonapi(
          Api::V1::PerformanceReviewSerializer.new(review).serializable_hash,
          meta: { message: "Performance review updated successfully." }
        )
      end

      # DELETE /api/v1/performance_reviews/:id
      def destroy
        authorize @review

        Api::V1::DeletePerformanceReviewService.new(review: @review).perform

        render_jsonapi({}, meta: { message: "Performance review deleted successfully." })
      end

      private

      def set_review
        @review = PerformanceReview.find(params[:id])
      end

      def review_params
        params.require(:performance_review).permit(
          :user_id, :period_start, :period_end, :review_date, :rating,
          :status, :summary, :strengths, :improvements
        )
      end
    end
  end
end
