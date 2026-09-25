# frozen_string_literal: true

module Api
  module V1
    class ListTasksService
      def initialize(args = {})
        @project_id = args[:project_id].presence
        @assignee_id = args[:assignee_id].presence
        @status = args[:status].presence
      end

      def perform
        scope = Task.includes(:project, :assignee).recent_first
        scope = scope.where(project_id: project_id) if project_id
        scope = scope.where(assignee_id: assignee_id) if assignee_id
        scope = scope.where(status: status) if status
        scope
      end

      private

      attr_reader :project_id, :assignee_id, :status
    end
  end
end
