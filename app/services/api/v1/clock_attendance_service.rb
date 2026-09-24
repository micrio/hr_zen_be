# frozen_string_literal: true

module Api
  module V1
    # Identifies a user from a face embedding and toggles clock in/out.
    class ClockAttendanceService
      def initialize(args)
        @organization = args[:organization]
        @embedding = args[:embedding]
        @now = args[:now] || Time.current
      end

      def perform
        match = Api::V1::FaceMatcher.new(
          embedding: embedding,
          embeddings: FaceEmbedding.where(organization: organization).includes(:user)
        ).perform

        unless match
          raise Api::Error::UnprocessableEntity.new(
            "Face not recognized",
            details: { embedding: [ "no matching employee found" ] }
          )
        end

        user = match.user

        {
          event: create_event(user, match.distance),
          user: user,
          distance: match.distance
        }
      end

      private

      attr_reader :organization, :embedding, :now

      def create_event(user, distance)
        AttendanceEvent.create!(
          organization: organization,
          user: user,
          kind: next_kind(user),
          occurred_at: now,
          distance: distance,
          source: "face"
        )
      end

      def next_kind(user)
        last = AttendanceEvent.where(organization: organization, user: user)
                              .recent_first.first
        last&.kind == "clock_in" ? "clock_out" : "clock_in"
      end
    end
  end
end
