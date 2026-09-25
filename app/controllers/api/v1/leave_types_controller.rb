# frozen_string_literal: true

module Api
  module V1
    class LeaveTypesController < BaseController
      plan_feature :leaves

      before_action :set_leave_type, only: %i[show update destroy]

      def index
        authorize LeaveType

        render_jsonapi(
          Api::V1::ListLeaveTypesService.new.perform.map do |leave_type|
            Api::V1::LeaveTypeSerializer.new(leave_type).serializable_hash
          end
        )
      end

      def show
        authorize @leave_type

        render_jsonapi(Api::V1::LeaveTypeSerializer.new(@leave_type).serializable_hash)
      end

      def create
        authorize LeaveType

        leave_type = Api::V1::CreateLeaveTypeService.new(
          attributes: leave_type_params
        ).perform

        render_jsonapi(
          Api::V1::LeaveTypeSerializer.new(leave_type).serializable_hash,
          status: :created,
          meta: { message: "Leave type created successfully." }
        )
      end

      def update
        authorize @leave_type

        leave_type = Api::V1::UpdateLeaveTypeService.new(
          leave_type: @leave_type,
          attributes: leave_type_params
        ).perform

        render_jsonapi(
          Api::V1::LeaveTypeSerializer.new(leave_type).serializable_hash,
          meta: { message: "Leave type updated successfully." }
        )
      end

      def destroy
        authorize @leave_type

        Api::V1::DeleteLeaveTypeService.new(leave_type: @leave_type).perform

        render_jsonapi({}, meta: { message: "Leave type deleted successfully." })
      end

      private

      def set_leave_type
        @leave_type = LeaveType.find(params[:id])
      end

      def leave_type_params
        params.require(:leave_type).permit(:name, :default_days, :active)
      end
    end
  end
end
