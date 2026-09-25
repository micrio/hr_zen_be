# frozen_string_literal: true

module Api
  module V1
    class DeleteTaskService
      def initialize(args)
        @task = args[:task]
      end

      def perform
        task.destroy!
      end

      private

      attr_reader :task
    end
  end
end
