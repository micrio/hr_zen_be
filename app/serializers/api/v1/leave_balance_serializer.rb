# frozen_string_literal: true

module Api
  module V1
    class LeaveBalanceSerializer < ActiveModel::Serializer
      attributes :id, :user_id, :leave_type_id, :entitled_days, :used_days,
                 :remaining_days, :created_at

      attribute :user_name
      attribute :leave_type_name

      def user_name
        object.user&.full_name
      end

      def leave_type_name
        object.leave_type&.name
      end

      def remaining_days
        object.remaining_days.to_f
      end

      def entitled_days
        object.entitled_days.to_f
      end

      def used_days
        object.used_days.to_f
      end
    end
  end
end
