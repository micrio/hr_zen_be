# frozen_string_literal: true

module Api
  module V1
    class TaskSerializer < ActiveModel::Serializer
      attributes :id, :title, :description, :project_id, :assignee_id, :status,
                 :priority, :due_date, :created_at

      attribute :project_name
      attribute :assignee_name

      def project_name
        object.project&.name
      end

      def assignee_name
        object.assignee&.full_name
      end
    end
  end
end
