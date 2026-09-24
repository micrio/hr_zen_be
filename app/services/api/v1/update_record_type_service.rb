# frozen_string_literal: true

module Api
  module V1
    class UpdateRecordTypeService
      def initialize(args)
        @record_type = args[:record_type]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(:name, :fields)
      end

      def perform
        record_type.update!(attributes)
        record_type
      end

      private

      attr_reader :record_type, :attributes
    end
  end
end
