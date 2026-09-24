# frozen_string_literal: true

module Api
  module V1
    class ListRecordTypesService
      def perform
        RecordType.includes(:permission_rules).order(:name)
      end
    end
  end
end
