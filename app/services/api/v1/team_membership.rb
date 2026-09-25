# frozen_string_literal: true

module Api
  module V1
    # Shared team member add/remove logic.
    module TeamMembership
      private

      def sync_members(team, member_ids)
        ids = Array(member_ids).reject(&:blank?).map(&:to_i).uniq

        ActsAsTenant.with_tenant(team.organization) do
          team.team_members.where.not(user_id: ids).destroy_all
          ids.each { |user_id| team.team_members.find_or_create_by!(user_id: user_id) }
        end
      end
    end
  end
end
