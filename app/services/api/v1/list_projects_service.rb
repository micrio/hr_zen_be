# frozen_string_literal: true

module Api
  module V1
    class ListProjectsService
      def initialize(args = {})
        @team_id = args[:team_id].presence
        @status = args[:status].presence
      end

      def perform
        scope = Project.includes(:team).recent_first
        scope = scope.where(team_id: team_id) if team_id
        scope = scope.where(status: status) if status
        scope
      end

      private

      attr_reader :team_id, :status
    end
  end
end
