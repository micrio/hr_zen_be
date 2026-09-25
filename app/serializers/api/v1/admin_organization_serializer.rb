# frozen_string_literal: true

module Api
  module V1
    class AdminOrganizationSerializer < ActiveModel::Serializer
      attributes :id, :name, :subdomain, :plan, :status, :created_at

      attribute :users_count

      def users_count
        object.users.size
      end
    end
  end
end
