# frozen_string_literal: true

module Api
  module V1
    class TeamSerializer < ActiveModel::Serializer
      attributes :id, :name, :description, :lead_id, :created_at

      attribute :lead_name
      attribute :member_ids
      attribute :members_count
      attribute :projects_count

      def lead_name
        object.lead&.full_name
      end

      def member_ids
        object.team_members.map(&:user_id)
      end

      def members_count
        object.team_members.size
      end

      def projects_count
        object.projects.size
      end
    end
  end
end
