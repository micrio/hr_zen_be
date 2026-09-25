# frozen_string_literal: true

module Api
  module V1
    class DeleteHolidayService
      def initialize(args)
        @holiday = args[:holiday]
      end

      def perform
        holiday.destroy!
      end

      private

      attr_reader :holiday
    end
  end
end
