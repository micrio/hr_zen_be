# frozen_string_literal: true

module Api
  module V1
    class UpdateTeamService
      include TeamMembership

      ATTRS = %i[name description lead_id].freeze

      def initialize(args)
        @team = args[:team]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
        @member_ids = args[:member_ids]
      end

      def perform
        ActiveRecord::Base.transaction do
          team.update!(attributes)
          sync_members(team, member_ids) unless member_ids.nil?
          team
        end
      end

      private

      attr_reader :team, :attributes, :member_ids
    end
  end
end
