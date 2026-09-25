# frozen_string_literal: true

module Api
  module V1
    class ListHolidaysService
      def initialize(args = {})
        @year = args[:year].presence
      end

      def perform
        Holiday.for_year(year)
      end

      private

      attr_reader :year
    end
  end
end
