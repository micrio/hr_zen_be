# frozen_string_literal: true

module Api
  module V1
    class UpdateProjectService
      ATTRS = %i[team_id name description status start_date end_date].freeze

      def initialize(args)
        @project = args[:project]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        project.update!(attributes)
        project
      end

      private

      attr_reader :project, :attributes
    end
  end
end
