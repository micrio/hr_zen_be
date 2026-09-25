# frozen_string_literal: true

module Api
  module V1
    class CreateTeamService
      include TeamMembership

      ATTRS = %i[name description lead_id].freeze

      def initialize(args)
        @organization = args[:organization]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
        @member_ids = args[:member_ids]
      end

      def perform
        ActiveRecord::Base.transaction do
          team = Team.new(attributes)
          team.organization = organization
          team.save!
          sync_members(team, member_ids) unless member_ids.nil?
          team
        end
      end

      private

      attr_reader :organization, :attributes, :member_ids
    end
  end
end
