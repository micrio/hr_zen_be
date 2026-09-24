# frozen_string_literal: true

module Api
  module V1
    class ListRecordEntriesService
      def initialize(args = {})
        @record_type_id = args[:record_type_id].presence
      end

      def perform
        scope = RecordEntry.includes(:record_type).order(created_at: :desc)
        scope = scope.where(record_type_id: record_type_id) if record_type_id
        scope
      end

      private

      attr_reader :record_type_id
    end
  end
end
