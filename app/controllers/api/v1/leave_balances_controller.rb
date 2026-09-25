# frozen_string_literal: true

module Api
  module V1
    class LeaveBalancesController < BaseController
      plan_feature :leaves

      before_action :set_balance, only: %i[update]

      # GET /api/v1/leave_balances?user_id=&leave_type_id=
      def index
        authorize LeaveBalance

        balances = Api::V1::ListLeaveBalancesService.new(
          user_id: params[:user_id],
          leave_type_id: params[:leave_type_id]
        ).perform

        render_jsonapi(
          balances.map do |balance|
            Api::V1::LeaveBalanceSerializer.new(balance).serializable_hash
          end
        )
      end

      # PATCH /api/v1/leave_balances/:id
      def update
        authorize @balance

        balance = Api::V1::UpdateLeaveBalanceService.new(
          balance: @balance,
          attributes: balance_params
        ).perform

        render_jsonapi(
          Api::V1::LeaveBalanceSerializer.new(balance).serializable_hash,
          meta: { message: "Leave balance updated successfully." }
        )
      end

      # POST /api/v1/leave_balances/populate
      def populate
        authorize LeaveBalance, :create?

        leave_type = LeaveType.find(params.require(:leave_type_id))

        result = Api::V1::PopulateLeaveBalancesService.new(
          organization: current_user.organization,
          leave_type: leave_type,
          user_ids: params[:user_ids]
        ).perform

        render_jsonapi(
          result,
          status: :created,
          meta: { message: "Created #{result[:created]} balance(s)." }
        )
      end

      private

      def set_balance
        @balance = LeaveBalance.find(params[:id])
      end

      def balance_params
        params.require(:leave_balance).permit(:entitled_days)
      end
    end
  end
end
