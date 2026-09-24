# frozen_string_literal: true

module Api
  module V1
    class DeleteFaceService
      def initialize(args)
        @user = args[:user]
      end

      def perform
        user.face_embeddings.destroy_all
      end

      private

      attr_reader :user
    end
  end
end
