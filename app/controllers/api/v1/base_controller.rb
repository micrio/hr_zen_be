# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include Devise::Controllers::Helpers
      include Pundit::Authorization
      include JsonRenderer
      include RescueExceptions
      include Secured
    end
  end
end
