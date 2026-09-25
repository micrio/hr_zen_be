# frozen_string_literal: true

module Api
  module V1
    # Aggregated, read-only report for the organization over a date range.
    class ReportSummaryService
      def initialize(args)
        @organization = args[:organization]
        @from = parse_date(args[:from]) || Date.current.beginning_of_month
        @to = parse_date(args[:to]) || Date.current.end_of_month
      end

      def perform
        ActsAsTenant.with_tenant(organization) do
          {
            range: { from: from, to: to },
            headcount: organization.users.count,
            attendance: attendance_report,
            leaves: leaves_report,
            payroll: payroll_report,
            holidays: holidays_report
          }
        end
      end

      private

      attr_reader :organization, :from, :to

      def attendance_report
        events = AttendanceEvent
                 .where(occurred_at: from.beginning_of_day..to.end_of_day)

        by_user = events.joins(:user)
                        .group("users.first_name", "users.last_name")
                        .distinct
                        .count(:occurred_at)

        {
          clock_ins: events.where(kind: "clock_in").count,
          clock_outs: events.where(kind: "clock_out").count,
          days_logged: events.pluck(:occurred_at).map(&:to_date).uniq.size,
          by_user: by_user.map do |(first, last), count|
            { user_name: [ first, last ].compact.join(" "), events: count }
          end
        }
      end

      def leaves_report
        applications = LeaveApplication.where(start_date: from..to)

        {
          pending: applications.where(status: "pending").count,
          approved: applications.where(status: "approved").count,
          days_used: applications.where(status: "approved").sum(:days).to_f,
          by_type: applications.where(status: "approved")
                               .joins(:leave_type)
                               .group("leave_types.name")
                               .sum(:days)
                               .transform_values(&:to_f)
        }
      end

      def payroll_report
        entries = PayrollEntry.where(period_start: from..to)

        {
          entries: entries.count,
          gross_total: entries.sum(:gross_amount).to_f,
          net_total: entries.sum(:net_amount).to_f,
          currency: entries.first&.currency || currency
        }
      end

      def holidays_report
        Holiday.where(date: from..to).count
      end

      def currency
        @currency ||= Api::V1::FindPayrollSettingService.new(
          organization: organization
        ).perform.currency
      end

      def parse_date(value)
        return nil if value.blank?

        Date.parse(value.to_s)
      rescue Date::Error
        nil
      end
    end
  end
end
