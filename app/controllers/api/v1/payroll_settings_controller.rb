# frozen_string_literal: true

module Api
  module V1
    class PayrollSettingsController < BaseController
      # GET /api/v1/payroll/setting
      def show
        authorize :payroll_setting, :show?

        render_jsonapi(Api::V1::PayrollSettingSerializer.new(setting).serializable_hash)
      end

      # PATCH /api/v1/payroll/setting
      def update
        authorize :payroll_setting, :update?

        setting.update!(setting_params)

        render_jsonapi(
          Api::V1::PayrollSettingSerializer.new(setting).serializable_hash,
          meta: { message: "Payroll settings updated." }
        )
      end

      private

      def setting
        @setting ||= Api::V1::FindPayrollSettingService.new(
          organization: current_user.organization
        ).perform
      end

      def setting_params
        params.require(:payroll_setting).permit(:currency, :default_salary_type)
      end
    end
  end
end
