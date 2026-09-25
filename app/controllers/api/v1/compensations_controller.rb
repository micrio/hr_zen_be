# frozen_string_literal: true

module Api
  module V1
    class CompensationsController < BaseController
      before_action :set_compensation, only: %i[update destroy]

      # GET /api/v1/compensations
      def index
        authorize Compensation

        compensations = Compensation.includes(:user).order(:created_at)

        render_jsonapi(
          compensations.map do |compensation|
            Api::V1::CompensationSerializer.new(compensation).serializable_hash
          end
        )
      end

      # POST /api/v1/compensations
      def create
        authorize Compensation

        user = User.find(params.require(:compensation).require(:user_id))

        compensation = Api::V1::UpsertCompensationService.new(
          organization: current_user.organization,
          user: user,
          attributes: compensation_params
        ).perform

        render_jsonapi(
          Api::V1::CompensationSerializer.new(compensation).serializable_hash,
          status: :created,
          meta: { message: "Compensation saved." }
        )
      end

      # PATCH /api/v1/compensations/:id
      def update
        authorize @compensation

        compensation = Api::V1::UpsertCompensationService.new(
          organization: current_user.organization,
          user: @compensation.user,
          attributes: compensation_params
        ).perform

        render_jsonapi(
          Api::V1::CompensationSerializer.new(compensation).serializable_hash,
          meta: { message: "Compensation updated." }
        )
      end

      # DELETE /api/v1/compensations/:id
      def destroy
        authorize @compensation

        @compensation.destroy!

        render_jsonapi({}, meta: { message: "Compensation removed." })
      end

      private

      def set_compensation
        @compensation = Compensation.find(params[:id])
      end

      def compensation_params
        params.require(:compensation).permit(:salary_type, :rate)
      end
    end
  end
end
