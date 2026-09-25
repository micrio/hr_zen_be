# frozen_string_literal: true

module Api
  module V1
    class UpdateTaskService
      ATTRS = %i[project_id assignee_id title description status priority due_date].freeze

      def initialize(args)
        @task = args[:task]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        task.update!(attributes)
        task
      end

      private

      attr_reader :task, :attributes
    end
  end
end
