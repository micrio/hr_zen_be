# frozen_string_literal: true

module Api
  module V1
    # Tabular report data (columns + rows) for one report kind over a range.
    class ReportRowsService
      KINDS = %w[attendance leaves payroll headcount].freeze

      def initialize(args)
        @organization = args[:organization]
        @kind = args[:kind].to_s
        @from = parse_date(args[:from]) || Date.current.beginning_of_month
        @to = parse_date(args[:to]) || Date.current.end_of_month
      end

      def perform
        ActsAsTenant.with_tenant(organization) do
          {
            report: kind,
            range: { from: from, to: to }
          }.merge(send(kind))
        end
      end

      private

      attr_reader :organization, :kind, :from, :to

      def attendance
        events = AttendanceEvent
                 .where(occurred_at: from.beginning_of_day..to.end_of_day)
                 .includes(:user)

        rows = events.group_by(&:user_id).map do |_user_id, list|
          user = list.first.user
          [
            user&.full_name || "Unknown",
            list.map { |event| event.occurred_at.to_date }.uniq.size,
            list.count { |event| event.kind == "clock_in" },
            list.count { |event| event.kind == "clock_out" }
          ]
        end

        {
          columns: [ "Employee", "Days logged", "Clock ins", "Clock outs" ],
          rows: rows.sort_by { |row| -row[1] }
        }
      end

      def leaves
        applications = LeaveApplication
                       .where(start_date: from..to)
                       .includes(:user, :leave_type)

        rows = applications.group_by { |app| [ app.user_id, app.leave_type_id ] }.map do |_key, list|
          first = list.first
          [
            first.user&.full_name || "Unknown",
            first.leave_type&.name || "—",
            list.select(&:approved?).sum { |app| app.days.to_f },
            list.count { |app| app.status == "pending" }
          ]
        end

        {
          columns: [ "Employee", "Leave type", "Approved days", "Pending" ],
          rows: rows.sort_by { |row| -row[2] }
        }
      end

      def payroll
        entries = PayrollEntry
                  .where(period_start: from..to)
                  .includes(:user)
                  .recent_first

        rows = entries.map do |entry|
          [
            entry.user&.full_name || "Unknown",
            "#{entry.period_start} → #{entry.period_end}",
            entry.salary_type,
            entry.units.to_f,
            entry.gross_amount.to_f.round(2),
            entry.net_amount.to_f.round(2),
            entry.currency
          ]
        end

        {
          columns: [ "Employee", "Period", "Type", "Units", "Gross", "Net", "Currency" ],
          rows: rows
        }
      end

      def headcount
        users = organization.users.includes(:roles).order(:first_name, :last_name)

        rows = users.map do |user|
          [
            user.full_name,
            user.email,
            user.roles.map(&:name).join(", "),
            user.confirmed? ? "Yes" : "No",
            user.created_at.to_date.to_s
          ]
        end

        {
          columns: [ "Name", "Email", "Roles", "Confirmed", "Joined" ],
          rows: rows
        }
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
