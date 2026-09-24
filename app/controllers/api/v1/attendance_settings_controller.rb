# frozen_string_literal: true

module Api
  module V1
    class AttendanceSettingsController < BaseController
      # GET /api/v1/attendance/setting
      def show
        authorize :attendance_setting, :show?

        render_jsonapi(setting_payload(setting))
      end

      # PATCH /api/v1/attendance/setting
      def update
        authorize :attendance_setting, :update?

        updated = Api::V1::UpdateAttendanceSettingService.new(
          setting: setting,
          attributes: setting_params
        ).perform

        render_jsonapi(
          setting_payload(updated),
          meta: { message: "Attendance settings updated." }
        )
      end

      private

      def setting
        @setting ||= Api::V1::FindAttendanceSettingService.new(
          organization: current_user.organization
        ).perform
      end

      def setting_params
        params.require(:attendance_setting).permit(:enabled, :cooldown_seconds)
      end

      def setting_payload(record)
        {
          enabled: record.enabled,
          clock_token: record.clock_token,
          cooldown_seconds: record.cooldown_seconds
        }
      end
    end
  end
end
