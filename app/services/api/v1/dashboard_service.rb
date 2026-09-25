# frozen_string_literal: true

module Api
  module V1
    # Data for the dashboard cards, filtered to the org's plan.
    class DashboardService
      CARD_FEATURES = {
        "headcount" => "users",
        "attendance_days" => "attendance",
        "attendance_by_user" => "attendance",
        "leave_days" => "leaves",
        "leave_by_type" => "leaves",
        "payroll_net" => "payroll",
        "holidays" => "holidays"
      }.freeze

      def initialize(args)
        @organization = args[:organization]
        @from = args[:from]
        @to = args[:to]
      end

      def perform
        summary = Api::V1::ReportSummaryService.new(
          organization: organization,
          from: from,
          to: to
        ).perform

        cards = build_cards(summary)

        { cards: cards, available: cards.keys }
      end

      private

      attr_reader :organization, :from, :to

      def allowed?(feature)
        organization.plan_allows?(feature)
      end

      def build_cards(summary)
        cards = {}

        if allowed?("users")
          cards["headcount"] = { value: summary[:headcount] }
        end

        if allowed?("attendance")
          cards["attendance_days"] = { value: summary[:attendance][:days_logged] }
          cards["attendance_by_user"] = {
            rows: summary[:attendance][:by_user].map { |row| [ row[:user_name], row[:events] ] }
          }
        end

        if allowed?("leaves")
          cards["leave_days"] = { value: summary[:leaves][:days_used] }
          cards["leave_by_type"] = {
            rows: summary[:leaves][:by_type].map { |name, days| [ name, days ] }
          }
        end

        if allowed?("payroll")
          cards["payroll_net"] = {
            value: summary[:payroll][:net_total],
            currency: summary[:payroll][:currency]
          }
        end

        cards["holidays"] = { value: summary[:holidays] } if allowed?("holidays")

        cards
      end
    end
  end
end
