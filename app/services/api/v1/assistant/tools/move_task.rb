# frozen_string_literal: true

module Api
  module V1
    module Assistant
      module Tools
        class MoveTask < RubyLLM::Tool
          description "Update a task's status. Identify the task by id or by " \
                      "its title (partial match). Use this to complete/move tasks."

          parameter :task, type: "string", required: true,
                           description: "Task id or title (partial match)"
          parameter :status, type: "string", required: true,
                             description: "todo | in_progress | blocked | done"

          def execute(task:, status:)
            unless Task::STATUSES.include?(status.to_s)
              return { error: "Invalid status. Use one of #{Task::STATUSES.join(', ')}" }
            end

            record = find_task(task)
            return { error: "No task found for #{task.inspect}" } if record.nil?

            record.update!(status: status.to_s)

            Assistant::References.add(
              type: "task", id: record.id, label: record.title, href: "/tasks"
            )

            { id: record.id, title: record.title, status: record.status }
          end

          private

          def find_task(value)
            if value.to_s.match?(/\A\d+\z/)
              Task.find_by(id: value.to_i)
            else
              Task.where("title ILIKE ?", "%#{value}%").order(:created_at).first
            end
          end
        end
      end
    end
  end
end
