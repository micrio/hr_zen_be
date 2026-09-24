# frozen_string_literal: true

module Api
  module V1
    class ListAttendanceEventsService
      def initialize(args)
        @organization = args[:organization]
        @user_id = args[:user_id].presence
        @day = args[:day].presence
      end

      def perform
        scope = AttendanceEvent.where(organization: organization)
                               .includes(:user)
                               .recent_first
        scope = scope.where(user_id: user_id) if user_id
        scope = scope.for_day(parsed_day) if parsed_day
        scope
      end

      private

      attr_reader :organization, :user_id, :day

      def parsed_day
        return @parsed_day if defined?(@parsed_day)

        @parsed_day = day ? Date.parse(day.to_s) : nil
      rescue Date::Error
        @parsed_day = nil
      end
    end
  end
end
