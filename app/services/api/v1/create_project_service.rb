# frozen_string_literal: true

module Api
  module V1
    class CreateProjectService
      ATTRS = %i[team_id name description status start_date end_date].freeze

      def initialize(args)
        @organization = args[:organization]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        project = Project.new(attributes)
        project.organization = organization
        project.save!
        project
      end

      private

      attr_reader :organization, :attributes
    end
  end
end
