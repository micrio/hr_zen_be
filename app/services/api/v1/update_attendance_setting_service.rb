# frozen_string_literal: true

module Api
  module V1
    class UpdateAttendanceSettingService
      ATTRS = %i[enabled cooldown_seconds].freeze

      def initialize(args)
        @setting = args[:setting]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        @setting.update!(@attributes)
        @setting
      end
    end
  end
end
