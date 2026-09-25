# frozen_string_literal: true

module Api
  module V1
    class ListActivitiesService
      DEFAULT_LIMIT = 200

      def initialize(args = {})
        @organization = args[:organization]
        @user_id = args[:user_id].presence
        @item_type = args[:item_type].presence
        @from = args[:from].presence
        @to = args[:to].presence
      end

      def perform
        scope = PaperTrail::Version.where(organization_id: organization.id)
                                   .order(created_at: :desc)
        scope = scope.where(whodunnit: user_id.to_s) if user_id
        scope = scope.where(item_type: item_type) if item_type
        scope = scope.where(created_at: parsed_from.beginning_of_day..) if parsed_from
        scope = scope.where(created_at: ..parsed_to.end_of_day) if parsed_to
        scope.limit(DEFAULT_LIMIT)
      end

      private

      attr_reader :organization, :user_id, :item_type, :from, :to

      def parsed_from
        @parsed_from ||= parse_date(from)
      end

      def parsed_to
        @parsed_to ||= parse_date(to)
      end

      def parse_date(value)
        return nil if value.blank?

        Date.parse(value.to_s)
      rescue Date::Error
        nil
      end
    end
  end
end
