# frozen_string_literal: true

module Api
  module V1
    class PayrollEntriesController < BaseController
      plan_feature :payroll

      # GET /api/v1/payroll_entries?user_id=
      def index
        authorize PayrollEntry

        entries = Api::V1::ListPayrollEntriesService.new(
          user_id: params[:user_id]
        ).perform

        render_jsonapi(
          entries.map do |entry|
            Api::V1::PayrollEntrySerializer.new(entry).serializable_hash
          end
        )
      end

      # POST /api/v1/payroll_entries  (calculate)
      def create
        authorize PayrollEntry

        user = User.find(params.require(:payroll_entry).require(:user_id))

        entry = Api::V1::CalculatePayrollService.new(
          organization: current_user.organization,
          user: user,
          period_start: entry_params[:period_start],
          period_end: entry_params[:period_end],
          units: entry_params[:units],
          adjustments: entry_params[:adjustments]
        ).perform

        render_jsonapi(
          Api::V1::PayrollEntrySerializer.new(entry).serializable_hash,
          status: :created,
          meta: { message: "Payroll calculated." }
        )
      end

      # DELETE /api/v1/payroll_entries/:id
      def destroy
        entry = PayrollEntry.find(params[:id])
        authorize entry

        entry.destroy!

        render_jsonapi({}, meta: { message: "Payroll entry deleted." })
      end

      private

      def entry_params
        params.require(:payroll_entry).permit(
          :user_id, :period_start, :period_end, :units,
          adjustments: %i[label kind amount]
        )
      end
    end
  end
end
