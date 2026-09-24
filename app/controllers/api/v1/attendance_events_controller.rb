# frozen_string_literal: true

module Api
  module V1
    class AttendanceEventsController < BaseController
      # GET /api/v1/attendance/events?user_id=&day=
      def index
        authorize AttendanceEvent

        events = Api::V1::ListAttendanceEventsService.new(
          organization: current_user.organization,
          user_id: target_user_id,
          day: params[:day]
        ).perform

        render_jsonapi(
          events.map do |event|
            Api::V1::AttendanceEventSerializer.new(event).serializable_hash
          end
        )
      end

      private

      def target_user_id
        return current_user.id unless current_user.has_role?("superadmin")
        return params[:user_id] if params[:user_id].present?

        nil # superadmins see all events in their organization
      end
    end
  end
end
