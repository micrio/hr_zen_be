# frozen_string_literal: true

module Api
  module V1
    class CreateHolidayService
      ATTRS = %i[name date recurring].freeze

      def initialize(args)
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        Holiday.create!(attributes)
      end

      private

      attr_reader :attributes
    end
  end
end
