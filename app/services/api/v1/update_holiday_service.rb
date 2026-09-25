# frozen_string_literal: true

module Api
  module V1
    class UpdateHolidayService
      ATTRS = %i[name date recurring].freeze

      def initialize(args)
        @holiday = args[:holiday]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        holiday.update!(attributes)
        holiday
      end

      private

      attr_reader :holiday, :attributes
    end
  end
end
