# frozen_string_literal: true

module Api
  module V1
    class TasksController < BaseController
      plan_feature :work

      before_action :set_task, only: %i[update destroy]

      def index
        authorize Task

        tasks = Api::V1::ListTasksService.new(
          project_id: params[:project_id],
          assignee_id: params[:assignee_id],
          status: params[:status]
        ).perform

        render_jsonapi(
          tasks.map { |task| Api::V1::TaskSerializer.new(task).serializable_hash }
        )
      end

      def create
        authorize Task

        task = Api::V1::CreateTaskService.new(
          organization: current_user.organization,
          attributes: task_params
        ).perform

        render_jsonapi(
          Api::V1::TaskSerializer.new(task).serializable_hash,
          status: :created,
          meta: { message: "Task created successfully." }
        )
      end

      def update
        authorize @task

        task = Api::V1::UpdateTaskService.new(
          task: @task,
          attributes: task_params
        ).perform

        render_jsonapi(
          Api::V1::TaskSerializer.new(task).serializable_hash,
          meta: { message: "Task updated successfully." }
        )
      end

      def destroy
        authorize @task

        Api::V1::DeleteTaskService.new(task: @task).perform

        render_jsonapi({}, meta: { message: "Task deleted successfully." })
      end

      private

      def set_task
        @task = Task.find(params[:id])
      end

      def task_params
        params.require(:task).permit(
          :project_id, :assignee_id, :title, :description, :status, :priority,
          :due_date
        )
      end
    end
  end
end
