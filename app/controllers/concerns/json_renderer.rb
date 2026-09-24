# frozen_string_literal: true

module JsonRenderer
  extend ActiveSupport::Concern

  # Renders the standard success envelope: { success:, data:, meta: }.
  def render_jsonapi(data, status: :ok, meta: {})
    render json: { success: true, data: data, meta: meta }, status: status
  end

  # Renders the standard error envelope: { success:, error:, details: }.
  def render_error_response(message, status: :unprocessable_entity, details: nil)
    payload = { success: false, error: message }
    payload[:details] = details if details.present?

    render json: payload, status: status
  end
end
