# frozen_string_literal: true

module Api
  module V1
    class ListRolesService
      def perform
        Role.includes(:user_roles, :permission_rules).order(:name)
      end
    end
  end
end
