# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      # Clients always send the fully-shaped payload; don't wrap under the controller name.
      wrap_parameters false

      include Devise::Controllers::Helpers
      include Pundit::Authorization
      include JsonRenderer
      include RescueExceptions
      include Secured
    end
  end
end
