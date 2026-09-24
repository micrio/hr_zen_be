# frozen_string_literal: true

module Api
  module V1
    # Extra user fields come from the "User" record type (Option B). Core
    # columns and level-2 sensitive fields are excluded from the user form.
    module UserCustomFields
      CORE_KEYS = %w[
        email first_name middle_name last_name password password_confirmation
      ].freeze
      SENSITIVE_LEVEL = 2

      def self.record_type
        RecordType.find_by(name: "User")
      end

      def self.definitions(record_type = self.record_type)
        return [] if record_type.blank?

        record_type.field_definitions.reject do |field|
          CORE_KEYS.include?(field["key"].to_s) ||
            field["level"].to_i >= SENSITIVE_LEVEL
        end
      end

      def self.validate!(raw, record_type = self.record_type)
        Api::V1::RecordEntryData.validate_fields!(
          definitions(record_type),
          raw || {}
        )
      end
    end
  end
end
