# frozen_string_literal: true

module Api
  module V1
    # Validates and coerces a record entry's `data` against its RecordType's
    # field definitions (Option B: dynamic fields, no migrations).
    module RecordEntryData
      module_function

      def validate!(record_type, raw)
        validate_fields!(record_type.field_definitions, raw)
      end

      def validate_fields!(field_definitions, raw)
        data = (raw || {}).to_h.stringify_keys
        errors = {}

        field_definitions.each do |field|
          key = field["key"].to_s
          value = data[key]

          if field["required"] && blank?(value)
            add_error(errors, key, "is required")
            next
          end

          next if blank?(value)

          coerced, error = coerce(field["type"].to_s, value, field)

          if error
            add_error(errors, key, error)
          else
            data[key] = coerced
          end
        end

        (data.keys - field_definitions.map { |field| field["key"].to_s }).each do |key|
          add_error(errors, key, "is not a defined field")
        end

        raise Api::Error::ValidationError.new(details: errors) if errors.any?

        data
      end

      def blank?(value)
        return true if value.nil?
        return value.strip.empty? if value.is_a?(String)

        value.respond_to?(:empty?) && value.empty?
      end

      def add_error(errors, key, message)
        (errors[key] ||= []) << message
      end

      def coerce(type, value, field)
        case type
        when "number"
          [ Float(value), nil ]
        when "boolean"
          [ ActiveModel::Type::Boolean.new.cast(value), nil ]
        when "date"
          [ Date.parse(value.to_s), nil ]
        when "select"
          options = Array(field["options"]).map(&:to_s)
          return [ value, "is not an allowed option" ] unless options.include?(value.to_s)

          [ value, nil ]
        else
          [ value.to_s, nil ]
        end
      rescue ArgumentError, TypeError
        [ value, "is invalid" ]
      end

      private_class_method :blank?, :add_error, :coerce
    end
  end
end
