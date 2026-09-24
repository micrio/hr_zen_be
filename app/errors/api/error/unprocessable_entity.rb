# frozen_string_literal: true

module Api
  module Error
    class UnprocessableEntity < BaseError
      def initialize(message = "Unprocessable entity", details: nil)
        super(message, status: :unprocessable_entity, details: details)
      end
    end
  end
end
