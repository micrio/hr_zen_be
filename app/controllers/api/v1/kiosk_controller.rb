# frozen_string_literal: true

module Api
  module V1
    # Public kiosk endpoints, addressed by the organization's clock token.
    class KioskController < BaseController
      include AttendanceClockRendering

      skip_before_action :authenticate_user!

      # GET /api/v1/kiosk/:token
      def show
        render_jsonapi(kiosk_payload)
      end

      # POST /api/v1/kiosk/:token/clock
      def clock
        setting = enabled_setting!

        result = Api::V1::ClockAttendanceService.new(
          organization: setting.organization,
          embedding: kiosk_params[:embedding],
          cooldown_seconds: setting.cooldown_seconds
        ).perform

        render_clock(result)
      end

      private

      def setting_by_token
        AttendanceSetting.find_by(clock_token: params[:token])
      end

      def enabled_setting!
        record = setting_by_token

        if record.nil? || !record.enabled
          raise Api::Error::NotFoundError, "Kiosk is not available"
        end

        record
      end

      def kiosk_payload
        record = enabled_setting!

        {
          organization: {
            name: record.organization.name,
            subdomain: record.organization.subdomain
          },
          enabled: record.enabled,
          cooldown_seconds: record.cooldown_seconds
        }
      end

      def kiosk_params
        params.require(:attendance).permit(embedding: [])
      end
    end
  end
end
