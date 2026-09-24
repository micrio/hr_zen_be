# frozen_string_literal: true

module Api
  module V1
    class DeleteRecordTypeService
      def initialize(args)
        @record_type = args[:record_type]
      end

      def perform
        guard_permission_rules!

        record_type.destroy!
      end

      private

      attr_reader :record_type

      def guard_permission_rules!
        return unless record_type.permission_rules.exists?

        raise Api::Error::UnprocessableEntity.new(
          "Record type cannot be deleted",
          details: { base: [ "Delete its permission rules first." ] }
        )
      end
    end
  end
end
