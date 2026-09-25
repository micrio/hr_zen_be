# frozen_string_literal: true

module Api
  module V1
    class AdminOrganizationSerializer < ActiveModel::Serializer
      attributes :id, :name, :subdomain, :plan, :status, :created_at

      attribute :users_count
      attribute :features
      attribute :limits

      def users_count
        # Bypass the tenant default scope: the platform admin counts *other* orgs.
        ActsAsTenant.without_tenant { object.users.count }
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
