# frozen_string_literal: true

module Api
  module V1
    class RoleSerializer < ActiveModel::Serializer
      attributes :id, :name, :users_count, :permission_rules_count, :created_at

      def users_count
        object.user_roles.size
      end

      def permission_rules_count
        object.permission_rules.size
      end
    end
  end
end
