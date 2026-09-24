# frozen_string_literal: true

module Api
  module V1
    class LeaveApplicationsController < BaseController
      before_action :set_application, only: %i[show update destroy]

      def index
        authorize LeaveApplication

        applications = Api::V1::ListLeaveApplicationsService.new(
          user_id: params[:user_id],
          leave_type_id: params[:leave_type_id],
          status: params[:status]
        ).perform

        render_jsonapi(
          applications.map do |application|
            Api::V1::LeaveApplicationSerializer.new(application).serializable_hash
          end
        )
      end

      def show
        authorize @application

        render_jsonapi(
          Api::V1::LeaveApplicationSerializer.new(@application).serializable_hash
        )
      end

      def create
        authorize LeaveApplication

        application = Api::V1::CreateLeaveApplicationService.new(
          organization: current_user.organization,
          attributes: application_params
        ).perform

        render_jsonapi(
          Api::V1::LeaveApplicationSerializer.new(application).serializable_hash,
          status: :created,
          meta: { message: "Leave application created successfully." }
        )
      end

      def update
        authorize @application

        application = Api::V1::UpdateLeaveApplicationService.new(
          application: @application,
          attributes: application_params
        ).perform

        render_jsonapi(
          Api::V1::LeaveApplicationSerializer.new(application).serializable_hash,
          meta: { message: "Leave application updated successfully." }
        )
      end

      def destroy
        authorize @application

        Api::V1::DeleteLeaveApplicationService.new(application: @application).perform

        render_jsonapi({}, meta: { message: "Leave application deleted successfully." })
      end

      private

      def set_application
        @application = LeaveApplication.find(params[:id])
      end

      def application_params
        params.require(:leave_application).permit(
          :user_id, :leave_type_id, :start_date, :end_date, :days, :status, :reason
        )
      end
    end
  end
end
