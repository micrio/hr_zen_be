# frozen_string_literal: true

module Api
  module V1
    class AttendanceController < BaseController
      # POST /api/v1/attendance/clock
      def clock
        authorize AttendanceEvent, :create?

        result = Api::V1::ClockAttendanceService.new(
          organization: current_user.organization,
          embedding: clock_params[:embedding]
        ).perform

        clocked_in = result[:event].kind == "clock_in"

        render_jsonapi(
          {
            event: Api::V1::AttendanceEventSerializer.new(result[:event]).serializable_hash,
            user: Api::V1::UserSerializer.new(result[:user]).serializable_hash
          },
          status: :created,
          meta: {
            message: clocked_in ? "Clocked in." : "Clocked out.",
            next_action: clocked_in ? "clock_out" : "clock_in",
            distance: result[:distance].round(4)
          }
        )
      end

      private

      def clock_params
        params.require(:attendance).permit(embedding: [])
      end
    end
  end
end
