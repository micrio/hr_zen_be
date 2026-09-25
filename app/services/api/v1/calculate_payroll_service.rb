# frozen_string_literal: true

module Api
  module V1
    # Computes a payslip from the employee's compensation + dynamic adjustments.
    #   gross = rate * units   (hourly / daily)
    #   gross = rate           (monthly)
    #   net   = gross + earnings - deductions
    # When `units` is blank for a daily employee, days are derived from
    # attendance events in the period.
    class CalculatePayrollService
      ADJUSTMENT_KINDS = %w[earning deduction].freeze

      def initialize(args)
        @organization = args[:organization]
        @user = args[:user]
        @period_start = args[:period_start]
        @period_end = args[:period_end]
        @units = args[:units]
        @adjustments = normalize_adjustments(args[:adjustments])
      end

      def perform
        compensation = Compensation.find_by(
          organization: organization,
          user: user
        )

        unless compensation
          raise Api::Error::UnprocessableEntity.new(
            "No compensation set for this employee",
            details: { user: [ "set a salary type and rate first" ] }
          )
        end

        units = resolved_units(compensation)
        gross = gross_amount(compensation, units)
        earnings = adjustments.select { |row| row["kind"] == "earning" }.sum { |row| row["amount"].to_f }
        deductions = adjustments.select { |row| row["kind"] == "deduction" }.sum { |row| row["amount"].to_f }

        PayrollEntry.create!(
          organization: organization,
          user: user,
          period_start: period_start,
          period_end: period_end,
          salary_type: compensation.salary_type,
          rate: compensation.rate,
          units: units,
          gross_amount: gross.round(2),
          net_amount: (gross + earnings - deductions).round(2),
          adjustments: adjustments,
          currency: currency,
          computed_at: Time.current
        )
      end

      private

      attr_reader :organization, :user, :period_start, :period_end, :units, :adjustments

      def gross_amount(compensation, units)
        rate = compensation.rate.to_f

        case compensation.salary_type
        when "hourly", "daily" then rate * units
        else rate
        end
      end

      def resolved_units(compensation)
        return units.to_f if units.present?

        return 0.0 unless compensation.salary_type == "daily"

        AttendanceEvent
          .where(organization: organization, user: user)
          .where(occurred_at: period_start.to_date.beginning_of_day..period_end.to_date.end_of_day)
          .pluck(:occurred_at)
          .map(&:to_date)
          .uniq
          .size
          .to_f
      end

      def currency
        @currency ||= Api::V1::FindPayrollSettingService.new(
          organization: organization
        ).perform.currency
      end

      def normalize_adjustments(value)
        Array(value).filter_map do |row|
          data = row.to_h.symbolize_keys
          kind = data[:kind].to_s
          next unless ADJUSTMENT_KINDS.include?(kind)

          {
            "label" => data[:label].to_s,
            "kind" => kind,
            "amount" => data[:amount].to_f
          }
        end
      end
    end
  end
end
