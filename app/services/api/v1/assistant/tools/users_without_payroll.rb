# frozen_string_literal: true

module Api
  module V1
    module Assistant
      module Tools
        class UsersWithoutPayroll < RubyLLM::Tool
          description "List employees who have no payroll entry in a date range " \
                      "(defaults to the current month)."

          parameter :from, type: "string", required: false, description: "ISO date (YYYY-MM-DD)"
          parameter :to, type: "string", required: false, description: "ISO date (YYYY-MM-DD)"

          def execute(from: nil, to: nil)
            organization = Assistant::Context.organization
            from_date = parse(from) || Date.current.beginning_of_month
            to_date = parse(to) || Date.current.end_of_month

            paid_user_ids = PayrollEntry
                            .where(period_start: from_date..to_date)
                            .distinct
                            .pluck(:user_id)

            employees = organization.users
                                    .where.not(id: paid_user_ids)
                                    .order(:first_name)

            employees.map do |user|
              Assistant::References.add(
                type: "user", id: user.id, label: user.full_name, href: "/payroll"
              )
              { id: user.id, name: user.full_name, email: user.email }
            end
          end

          private

          def parse(value)
            return nil if value.blank?

            Date.parse(value.to_s)
          rescue Date::Error
            nil
          end
        end
      end
    end
  end
end
