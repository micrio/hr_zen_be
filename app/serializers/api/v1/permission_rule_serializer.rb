# frozen_string_literal: true

module Api
  module V1
    class PermissionRuleSerializer < ActiveModel::Serializer
      attributes :id, :role_id, :record_type_id, :perm_level, :created_at,
                 *PermissionRule::ACTIONS
    end
  end
end
