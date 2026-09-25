# frozen_string_literal: true

module Api
  module V1
    class ListTeamsService
      def perform
        Team.includes(:lead, :team_members).order(:name)
      end
    end
  end
end
