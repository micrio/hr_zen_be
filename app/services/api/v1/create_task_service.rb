# frozen_string_literal: true

module Api
  module V1
    class CreateTaskService
      ATTRS = %i[project_id assignee_id title description status priority due_date].freeze

      def initialize(args)
        @organization = args[:organization]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        task = Task.new(attributes)
        task.organization = organization
        task.save!
        task
      end

      private

      attr_reader :organization, :attributes
    end
  end
end
