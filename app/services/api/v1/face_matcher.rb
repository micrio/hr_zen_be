# frozen_string_literal: true

module Api
  module V1
    # 1:N face identification using Euclidean distance between descriptors.
    # Lower distance = closer match. Returns nil when no embedding is within
    # the threshold.
    class FaceMatcher
      DEFAULT_THRESHOLD = 0.55
      Match = Struct.new(:user, :distance, :face_embedding, keyword_init: true)

      def initialize(args)
        @embedding = Array(args[:embedding]).map(&:to_f)
        @embeddings = args[:embeddings]
        @threshold = (args[:threshold] || ENV.fetch("FACE_MATCH_THRESHOLD", DEFAULT_THRESHOLD)).to_f
      end

      def perform
        return nil if embedding.empty?

        best = nil

        embeddings.each do |face_embedding|
          distance = self.class.euclidean_distance(
            embedding,
            Array(face_embedding.vector).map(&:to_f)
          )
          next if distance.nil?

          if best.nil? || distance < best.distance
            best = Match.new(
              user: face_embedding.user,
              distance: distance,
              face_embedding: face_embedding
            )
          end
        end

        best if best && best.distance <= threshold
      end

      def self.euclidean_distance(first, second)
        return nil unless first.length == second.length && first.any?

        Math.sqrt(first.zip(second).sum { |a, b| (a - b)**2 })
      end

      private

      attr_reader :embedding, :embeddings, :threshold
    end
  end
end
