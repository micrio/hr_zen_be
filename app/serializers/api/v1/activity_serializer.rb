# frozen_string_literal: true

module Api
  module V1
    # Wraps a PaperTrail::Version as a readable activity row.
    class ActivitySerializer
      def initialize(version, actors: {})
        @version = version
        @actors = actors
      end

      def serializable_hash
        {
          id: version.id,
          event: version.event,
          item_type: version.item_type,
          item_id: version.item_id,
          actor_id: version.whodunnit.presence&.to_i,
          actor_name: actor_name,
          changes: changes,
          created_at: version.created_at
        }
      end

      private

      attr_reader :version, :actors

      def actor_name
        return nil if version.whodunnit.blank?

        actors[version.whodunnit.to_i]&.full_name
      end

      def changes
        raw = version.object_changes.presence || version.object
        return {} if raw.blank?

        YAML.unsafe_load(raw) || {}
      rescue StandardError
        {}
      end
    end
  end
end
