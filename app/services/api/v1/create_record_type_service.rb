# frozen_string_literal: true

module Api
  module V1
    class CreateRecordTypeService
      def initialize(args)
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(:name, :fields)
      end

      def perform
        RecordType.create!(attributes)
      end

      private

      attr_reader :attributes
    end
  end
end
