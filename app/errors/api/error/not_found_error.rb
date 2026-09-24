# frozen_string_literal: true

module Api
  module Error
    class NotFoundError < BaseError
      def initialize(message = "Resource not found", details: nil)
        super(message, status: :not_found, details: details)
      end
    end
  end
end
