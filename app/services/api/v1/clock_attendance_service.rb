# frozen_string_literal: true

module Api
  module V1
    # Identifies a user from a face embedding and toggles clock in/out.
    # A cooldown prevents a single person from clocking in and straight back
    # out on consecutive scans.
    class ClockAttendanceService
      def initialize(args)
        @organization = args[:organization]
        @embedding = args[:embedding]
        @cooldown_seconds = args[:cooldown_seconds].to_i
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
        last = AttendanceEvent.where(organization: organization, user: user)
                              .recent_first.first

        if within_cooldown?(last)
          return result(user, last, match.distance, skipped: true)
        end

        result(user, create_event(user, match.distance), match.distance, skipped: false)
      end

      private

      attr_reader :organization, :embedding, :cooldown_seconds, :now

      def result(user, event, distance, skipped:)
        {
          event: event,
          user: user,
          distance: distance,
          skipped: skipped,
          cooldown_remaining: skipped ? remaining(last_event_time(event)) : 0
        }
      end

      def last_event_time(event)
        event&.occurred_at
      end

      def within_cooldown?(last)
        return false if last.nil? || cooldown_seconds <= 0

        (now - last.occurred_at) < cooldown_seconds
      end

      def remaining(occurred_at)
        return 0 if occurred_at.nil?

        (cooldown_seconds - (now - occurred_at)).ceil.clamp(0, cooldown_seconds)
      end

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
