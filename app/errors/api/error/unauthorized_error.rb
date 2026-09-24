# frozen_string_literal: true

module Api
  module Error
    class UnauthorizedError < BaseError
      def initialize(message = "Unauthorized", details: nil)
        super(message, status: :unauthorized, details: details)
      end
    end
  end
end
