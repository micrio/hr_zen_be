# frozen_string_literal: true

module Api
  module V1
    class AttendanceController < BaseController
      include AttendanceClockRendering

      # POST /api/v1/attendance/clock
      def clock
        authorize AttendanceEvent, :create?

        organization = current_user.organization
        setting = Api::V1::FindAttendanceSettingService.new(
          organization: organization
        ).perform

        result = Api::V1::ClockAttendanceService.new(
          organization: organization,
          embedding: clock_params[:embedding],
          cooldown_seconds: setting.cooldown_seconds
        ).perform

        render_clock(result)
      end

      private

      def clock_params
        params.require(:attendance).permit(embedding: [])
      end
    end
  end
end
