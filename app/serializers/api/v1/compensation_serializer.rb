# frozen_string_literal: true

module Api
  module V1
    class CompensationSerializer < ActiveModel::Serializer
      attributes :id, :user_id, :salary_type, :rate, :created_at

      attribute :user_name

      def user_name
        object.user&.full_name
      end

      def rate
        object.rate.to_f
      end
    end
  end
end
