# frozen_string_literal: true

module Api
  module V1
    class UpdateRecordEntryService
      def initialize(args)
        @record_entry = args[:record_entry]
        @raw_data = args[:data]
      end

      def perform
        merged = record_entry.data.to_h.merge((raw_data || {}).to_h.stringify_keys)
        data = Api::V1::RecordEntryData.validate!(record_entry.record_type, merged)

        record_entry.update!(data: data)
        record_entry
      end

      private

      attr_reader :record_entry, :raw_data
    end
  end
end
