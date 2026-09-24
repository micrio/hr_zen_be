# frozen_string_literal: true

module Api
  module V1
    # Shared leave balance math used by the application services.
    module LeaveBalanceAdjuster
      private

      def balance_for(application)
        LeaveBalance.find_or_create_by!(
          organization: application.organization,
          user: application.user,
          leave_type: application.leave_type
        ) do |balance|
          balance.entitled_days = application.leave_type.default_days
        end
      end

      def deduct_balance!(application)
        balance = balance_for(application)

        if balance.remaining_days < application.days
          raise Api::Error::UnprocessableEntity.new(
            "Insufficient leave balance",
            details: {
              days: [ "exceeds remaining #{balance.remaining_days.to_f} day(s)" ]
            }
          )
        end

        balance.update!(used_days: balance.used_days + application.days)
      end

      def refund_balance!(application)
        balance = balance_for(application)
        balance.update!(used_days: [ balance.used_days - application.days, 0 ].max)
      end
    end
  end
end
