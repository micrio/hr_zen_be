# frozen_string_literal: true

module Api
  module V1
    class AttendanceEventSerializer < ActiveModel::Serializer
      attributes :id, :user_id, :kind, :occurred_at, :distance, :source,
                 :created_at

      attribute :user_name

      def user_name
        object.user&.full_name
      end
    end
  end
end
