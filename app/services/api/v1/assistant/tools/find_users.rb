# frozen_string_literal: true

module Api
  module V1
    module Assistant
      module Tools
        class FindUsers < RubyLLM::Tool
          description "Find employees in the current organization. " \
                      "Use confirmed=false for pending/unconfirmed users, " \
                      "and order='recent' to sort by newest first."

          parameter :confirmed, type: "boolean", required: false,
                                description: "true = confirmed only, false = unconfirmed only"
          parameter :limit, type: "integer", required: false,
                            description: "Max results (default 5)"
          parameter :order, type: "string", required: false,
                            description: "'recent' to sort newest first"

          def execute(confirmed: nil, limit: 5, order: nil)
            organization = Assistant::Context.organization
            scope = organization.users.includes(:roles)
            scope = order == "recent" ? scope.order(created_at: :desc) : scope.order(:first_name)
            scope = scope.where(confirmed_at: nil) if confirmed == false
            scope = scope.where.not(confirmed_at: nil) if confirmed == true

            employees = scope.limit(limit.to_i.clamp(1, 25))

            employees.map do |user|
              Assistant::References.add(
                type: "user", id: user.id, label: user.full_name, href: "/users"
              )
              { id: user.id, name: user.full_name, email: user.email, confirmed: user.confirmed? }
            end
          end
        end
      end
    end
  end
end
