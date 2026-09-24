# frozen_string_literal: true

module Api
  module V1
    class CreateRecordEntryService
      def initialize(args)
        @record_type = args[:record_type]
        @raw_data = args[:data]
      end

      def perform
        data = Api::V1::RecordEntryData.validate!(record_type, raw_data)

        RecordEntry.create!(record_type: record_type, data: data)
      end

      private

      attr_reader :record_type, :raw_data
    end
  end
end
