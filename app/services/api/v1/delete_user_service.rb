# frozen_string_literal: true

module Api
  module V1
    class DeleteUserService
      def initialize(args)
        @user = args[:user]
      end

      def perform
        user.destroy!
      end

      private

      attr_reader :user
    end
  end
end
