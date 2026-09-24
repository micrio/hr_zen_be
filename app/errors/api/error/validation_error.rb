# frozen_string_literal: true

module Api
  module Error
    # Carries field-level validation messages: { field => [message, ...] }.
    class ValidationError < UnprocessableEntity
      def initialize(message = "Validation failed", details: {})
        super(message, details: details)
      end

      def self.from_record(record)
        new(details: record.errors.to_hash)
      end
    end
  end
end
