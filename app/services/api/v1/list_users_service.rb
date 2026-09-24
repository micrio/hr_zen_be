# frozen_string_literal: true

module Api
  module V1
    class ListUsersService
      DEFAULT_PER_PAGE = 25
      MAX_PER_PAGE = 100

      def initialize(args = {})
        @page = args[:page].presence || 1
        @per_page = (args[:per_page].presence || DEFAULT_PER_PAGE).to_i.clamp(1, MAX_PER_PAGE)
        @query = args[:query].to_s.strip
      end

      def perform
        scope = User.includes(user_roles: :role).order(:created_at)

        if query.present?
          pattern = "%#{query}%"
          scope = scope.where(
            "email ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q",
            q: pattern
          )
        end

        scope.page(page).per(per_page)
      end

      private

      attr_reader :page, :per_page, :query
    end
  end
end
