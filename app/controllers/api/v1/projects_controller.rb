# frozen_string_literal: true

module Api
  module V1
    class ProjectsController < BaseController
      before_action :set_project, only: %i[update destroy]

      def index
        authorize Project

        projects = Api::V1::ListProjectsService.new(
          team_id: params[:team_id],
          status: params[:status]
        ).perform

        render_jsonapi(
          projects.map do |project|
            Api::V1::ProjectSerializer.new(project).serializable_hash
          end
        )
      end

      def create
        authorize Project

        project = Api::V1::CreateProjectService.new(
          organization: current_user.organization,
          attributes: project_params
        ).perform

        render_jsonapi(
          Api::V1::ProjectSerializer.new(project).serializable_hash,
          status: :created,
          meta: { message: "Project created successfully." }
        )
      end

      def update
        authorize @project

        project = Api::V1::UpdateProjectService.new(
          project: @project,
          attributes: project_params
        ).perform

        render_jsonapi(
          Api::V1::ProjectSerializer.new(project).serializable_hash,
          meta: { message: "Project updated successfully." }
        )
      end

      def destroy
        authorize @project

        Api::V1::DeleteProjectService.new(project: @project).perform

        render_jsonapi({}, meta: { message: "Project deleted successfully." })
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def project_params
        params.require(:project).permit(
          :team_id, :name, :description, :status, :start_date, :end_date
        )
      end
    end
  end
end
