# frozen_string_literal: true

module Api
  module V1
    class UpdateLeaveBalanceService
      def initialize(args)
        @balance = args[:balance]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(:entitled_days)
      end

      def perform
        balance.update!(attributes)
        balance
      end

      private

      attr_reader :balance, :attributes
    end
  end
end
