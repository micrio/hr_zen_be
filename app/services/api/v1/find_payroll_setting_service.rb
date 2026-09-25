# frozen_string_literal: true

module Api
  module V1
    class FindPayrollSettingService
      def initialize(args)
        @organization = args[:organization]
      end

      def perform
        ActsAsTenant.with_tenant(organization) do
          PayrollSetting.find_or_create_by!(organization: organization)
        end
      end

      private

      attr_reader :organization
    end
  end
end
