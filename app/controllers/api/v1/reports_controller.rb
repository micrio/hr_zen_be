# frozen_string_literal: true

module Api
  module V1
    class ReportsController < BaseController
      plan_feature :reports

      # GET /api/v1/reports/summary?from=&to=
      def summary
        summary = Api::V1::ReportSummaryService.new(
          organization: current_user.organization,
          from: params[:from],
          to: params[:to]
        ).perform

        render_jsonapi(summary)
      end
    end
  end
end
