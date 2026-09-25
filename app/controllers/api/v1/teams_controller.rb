# frozen_string_literal: true

module Api
  module V1
    class TeamsController < BaseController
      plan_feature :work

      before_action :set_team, only: %i[update destroy]

      def index
        authorize Team

        teams = Api::V1::ListTeamsService.new.perform

        render_jsonapi(
          teams.map { |team| Api::V1::TeamSerializer.new(team).serializable_hash }
        )
      end

      def create
        authorize Team

        team = Api::V1::CreateTeamService.new(
          organization: current_user.organization,
          attributes: team_params,
          member_ids: params[:member_ids]
        ).perform

        render_jsonapi(
          Api::V1::TeamSerializer.new(team).serializable_hash,
          status: :created,
          meta: { message: "Team created successfully." }
        )
      end

      def update
        authorize @team

        team = Api::V1::UpdateTeamService.new(
          team: @team,
          attributes: team_params,
          member_ids: params.key?(:member_ids) ? params[:member_ids] : nil
        ).perform

        render_jsonapi(
          Api::V1::TeamSerializer.new(team).serializable_hash,
          meta: { message: "Team updated successfully." }
        )
      end

      def destroy
        authorize @team

        Api::V1::DeleteTeamService.new(team: @team).perform

        render_jsonapi({}, meta: { message: "Team deleted successfully." })
      end

      private

      def set_team
        @team = Team.find(params[:id])
      end

      def team_params
        params.require(:team).permit(:name, :description, :lead_id)
      end
    end
  end
end
