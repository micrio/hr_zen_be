# frozen_string_literal: true

module Api
  module V1
    # Tells the client what the current organization's plan allows.
    class EntitlementsController < BaseController
      # GET /api/v1/entitlements
      def show
        render_jsonapi(current_user.organization.entitlements)
      end
    end
  end
end
