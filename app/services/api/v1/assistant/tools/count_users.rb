# frozen_string_literal: true

module Api
  module V1
    module Assistant
      module Tools
        class CountUsers < RubyLLM::Tool
          description "Count employees in the current organization, optionally " \
                      "filtered by confirmation status."

          parameter :confirmed, type: "boolean", required: false,
                                description: "true = confirmed only, false = unconfirmed only, omit for all"

          def execute(confirmed: nil)
            scope = Assistant::Context.organization.users

            if confirmed == false
              return { total: scope.where(confirmed_at: nil).count }
            end
            return { total: scope.where.not(confirmed_at: nil).count } if confirmed == true

            { total: scope.count }
          end
        end
      end
    end
  end
end
