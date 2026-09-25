# frozen_string_literal: true

module Api
  module V1
    class DashboardController < BaseController
      SPANS = %w[sm md lg].freeze
      MAX_CARDS = 24

      # GET /api/v1/dashboard
      def show
        data = Api::V1::DashboardService.new(
          organization: current_user.organization,
          from: params[:from],
          to: params[:to]
        ).perform

        render_jsonapi(data.merge(layout: current_user.dashboard_layout))
      end

      # PATCH /api/v1/dashboard
      def update
        layout = sanitize_layout(params[:layout])

        current_user.update!(dashboard_layout: layout)

        render_jsonapi({ layout: layout }, meta: { message: "Dashboard updated." })
      end

      private

      def sanitize_layout(raw)
        Array(raw).filter_map do |entry|
          key = entry[:key].to_s
          span = entry[:span].to_s

          next unless Api::V1::DashboardService::CARD_FEATURES.key?(key)
          next unless SPANS.include?(span)

          { "key" => key, "span" => span }
        end.first(MAX_CARDS)
      end
    end
  end
end
