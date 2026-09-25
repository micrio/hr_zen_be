# frozen_string_literal: true

module Api
  module V1
    class AdminOrganizationSerializer < ActiveModel::Serializer
      attributes :id, :name, :subdomain, :plan, :status, :created_at

      attribute :users_count
      attribute :features
      attribute :limits

      def users_count
        object.users.size
      end

      def features
        object.entitlements[:features]
      end

      def limits
        object.entitlements[:limits]
      end
    end
  end
end
