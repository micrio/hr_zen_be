# frozen_string_literal: true

module Api
  module V1
    class DeleteTeamService
      def initialize(args)
        @team = args[:team]
      end

      def perform
        team.destroy!
      end

      private

      attr_reader :team
    end
  end
end
