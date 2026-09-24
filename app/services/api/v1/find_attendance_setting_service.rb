# frozen_string_literal: true

module Api
  module V1
    class FindAttendanceSettingService
      def initialize(args)
        @organization = args[:organization]
      end

      def perform
        ActsAsTenant.with_tenant(organization) do
          AttendanceSetting.find_or_create_by!(organization: organization) do |setting|
            setting.cooldown_seconds = AttendanceSetting::DEFAULT_COOLDOWN_SECONDS
          end
        end
      end

      private

      attr_reader :organization
    end
  end
end
