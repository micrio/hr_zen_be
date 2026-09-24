# frozen_string_literal: true

module Api
  module V1
    class LeaveApplicationSerializer < ActiveModel::Serializer
      attributes :id, :user_id, :leave_type_id, :start_date, :end_date, :days,
                 :status, :reason, :created_at

      attribute :user_name
      attribute :leave_type_name

      def user_name
        object.user&.full_name
      end

      def leave_type_name
        object.leave_type&.name
      end

      def days
        object.days.to_f
      end
    end
  end
end
