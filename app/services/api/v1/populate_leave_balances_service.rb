# frozen_string_literal: true

module Api
  module V1
    # Creates a balance for every employee (or the given users) using the
    # leave type's default entitlement.
    class PopulateLeaveBalancesService
      def initialize(args)
        @organization = args[:organization]
        @leave_type = args[:leave_type]
        @user_ids = Array(args[:user_ids]).reject(&:blank?).map(&:to_i)
      end

      def perform
        users = organization.users
        users = users.where(id: user_ids) if user_ids.any?

        created = 0

        ActiveRecord::Base.transaction do
          users.find_each do |user|
            LeaveBalance.find_or_create_by!(
              organization: organization,
              user: user,
              leave_type: leave_type
            ) do |balance|
              balance.entitled_days = leave_type.default_days
              created += 1
            end
          end
        end

        { created: created, users: users.count }
      end

      private

      attr_reader :organization, :leave_type, :user_ids
    end
  end
end
