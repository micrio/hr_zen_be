# frozen_string_literal: true

module Api
  module V1
    class ProjectSerializer < ActiveModel::Serializer
      attributes :id, :name, :description, :team_id, :status, :start_date,
                 :end_date, :created_at

      attribute :team_name
      attribute :tasks_count

      def team_name
        object.team&.name
      end

      def tasks_count
        object.tasks.size
      end
    end
  end
end
