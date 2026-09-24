# frozen_string_literal: true

module Api
  module V1
    class RecordTypeSerializer < ActiveModel::Serializer
      attributes :id, :name, :fields, :field_levels, :permission_rules_count, :created_at

      def permission_rules_count
        object.permission_rules.size
      end
    end
  end
end
