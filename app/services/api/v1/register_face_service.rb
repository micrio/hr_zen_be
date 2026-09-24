# frozen_string_literal: true

module Api
  module V1
    # Stores a face descriptor (embedding) for a user. Multiple embeddings per
    # user improve recognition; all are used at match time.
    class RegisterFaceService
      def initialize(args)
        @user = args[:user]
        @embedding = args[:embedding]
        @source = args[:source].presence || "camera"
      end

      def perform
        user.face_embeddings.create!(
          vector: Array(embedding).map(&:to_f),
          source: source
        )
      end

      private

      attr_reader :user, :embedding, :source
    end
  end
end
