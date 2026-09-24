# frozen_string_literal: true

module Api
  module V1
    class DeleteRecordEntryService
      def initialize(args)
        @record_entry = args[:record_entry]
      end

      def perform
        record_entry.destroy!
      end

      private

      attr_reader :record_entry
    end
  end
end
