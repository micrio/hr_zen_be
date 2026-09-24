# frozen_string_literal: true

module Api
  module Error
    class InternalServerError < BaseError
      def initialize(message = "Internal server error", details: nil)
        super(message, status: :internal_server_error, details: details)
      end
    end
  end
end
