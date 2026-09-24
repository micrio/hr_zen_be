# frozen_string_literal: true

module Api
  module Error
    class ForbiddenError < BaseError
      def initialize(message = "Forbidden", details: nil)
        super(message, status: :forbidden, details: details)
      end
    end
  end
end
