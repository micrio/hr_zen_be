# frozen_string_literal: true

module Api
  module Error
    class BaseError < StandardError
      attr_reader :status, :details

      def initialize(message = nil, status: :unprocessable_entity, details: nil)
        @status = status
        @details = details
        super(message || default_message)
      end

      private

      def default_message
        self.class.name.demodulize.titleize
      end
    end
  end
end
