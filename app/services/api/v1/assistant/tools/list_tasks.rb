# frozen_string_literal: true

module Api
  module V1
    module Assistant
      module Tools
        class ListTasks < RubyLLM::Tool
          description "List tasks, optionally filtered by status or project name."

          parameter :status, type: "string", required: false,
                             description: "todo | in_progress | blocked | done"
          parameter :project, type: "string", required: false,
                              description: "Project name (partial match)"
          parameter :limit, type: "integer", required: false

          def execute(status: nil, project: nil, limit: 10)
            scope = Task.includes(:assignee, :project).order(:due_date)
            scope = scope.where(status: status) if status.present?
            if project.present?
              scope = scope.joins(:project).where("projects.name ILIKE ?", "%#{project}%")
            end

            scope.limit(limit.to_i.clamp(1, 25)).map do |task|
              Assistant::References.add(
                type: "task", id: task.id, label: task.title, href: "/tasks"
              )
              {
                id: task.id, title: task.title, status: task.status,
                priority: task.priority, project: task.project&.name,
                assignee: task.assignee&.full_name
              }
            end
          end
        end
      end
    end
  end
end
