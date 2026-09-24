# frozen_string_literal: true

module RescueExceptions
  extend ActiveSupport::Concern

  included do
    rescue_from Api::Error::BaseError, with: :render_api_error
    rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
  end

  private

  def render_api_error(error)
    render_error_response(error.message, status: error.status, details: error.details)
  end

  def render_record_invalid(error)
    render_error_response(
      "Validation failed",
      status: :unprocessable_entity,
      details: error.record.errors.to_hash
    )
  end

  def render_not_found(_error)
    render_error_response("Resource not found", status: :not_found)
  end

  def render_parameter_missing(error)
    render_error_response(error.message, status: :bad_request)
  end

  def render_forbidden(_error)
    render_error_response("You are not authorized to perform this action", status: :forbidden)
  end
end
