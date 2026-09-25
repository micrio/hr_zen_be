# frozen_string_literal: true

module Api
  module V1
    class DeleteProjectService
      def initialize(args)
        @project = args[:project]
      end

      def perform
        project.destroy!
      end

      private

      attr_reader :project
    end
  end
end
