# frozen_string_literal: true

require "pdf-reader"

module Api
  module V1
    # Extracts profile fields (email, name, phone) from an uploaded PDF using
    # text extraction + heuristics. Values are suggestions for the create-user
    # form; the client reviews and submits them.
    class PdfProfileExtractor
      MAX_BYTES = 5.megabytes
      ALLOWED_CONTENT_TYPES = %w[application/pdf].freeze
      MAX_RAW_TEXT = 20_000

      EMAIL = /[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}/i
      PHONE = /(?:\+?\d[\d\s().-]{7,}\d)/
      FULL_NAME_LABEL = /(?:full\s*name|name)\s*[:\-]\s*(.+)/i
      FIRST_NAME_LABEL = /first\s*name\s*[:\-]\s*(.+)/i
      MIDDLE_NAME_LABEL = /middle\s*name\s*[:\-]\s*(.+)/i
      LAST_NAME_LABEL = /last\s*name\s*[:\-]\s*(.+)/i
      NAME_LINE = /\A([A-Z][a-z]+(?:\s+[A-Z][a-z.'-]*){1,2})\z/

      def initialize(args)
        @io = args[:io]
        @filename = args[:filename]
        @content_type = args[:content_type]
        @byte_size = args[:byte_size]
      end

      def perform
        validate!

        text = extract_text

        {
          fields: self.class.parse_text(text),
          meta: { pages: pages_count, characters: text.length, filename: filename }
        }
      end

      # Pure text parser (kept separate so it can be unit-tested / swapped for OCR).
      def self.parse_text(text)
        source = text.to_s
        fields = {}

        email = source[EMAIL]
        fields[:email] = email.downcase if email

        phone = source[PHONE]&.strip
        fields[:phone] = phone if phone

        first = labelled(source, FIRST_NAME_LABEL)
        middle = labelled(source, MIDDLE_NAME_LABEL)
        last = labelled(source, LAST_NAME_LABEL)

        if first.nil? && last.nil?
          full = labelled(source, FULL_NAME_LABEL) || first_name_like_line(source)
          if full
            parts = full.split(/\s+/)
            first = parts.shift
            last = parts.pop if parts.length >= 1
            middle = parts.join(" ") if parts.length >= 1
          end
        end

        fields[:first_name] = clean(first) if first
        fields[:middle_name] = clean(middle) if middle
        fields[:last_name] = clean(last) if last

        fields.compact
      end

      def self.labelled(source, regex)
        match = source.match(regex)
        match && match[1]
      end
      private_class_method :labelled

      def self.first_name_like_line(source)
        source.each_line do |line|
          candidate = line.strip
          return candidate if candidate.match?(NAME_LINE)
        end
        nil
      end
      private_class_method :first_name_like_line

      def self.clean(value)
        value.to_s.strip.gsub(/\s+/, " ")
      end
      private_class_method :clean

      private

      attr_reader :io, :filename, :content_type, :byte_size

      def validate!
        if io.blank?
          raise Api::Error::UnprocessableEntity.new(
            "PDF is required", details: { file: [ "is required" ] }
          )
        end

        if content_type.present? && !ALLOWED_CONTENT_TYPES.include?(content_type)
          raise Api::Error::UnprocessableEntity.new(
            "Unsupported file type", details: { file: [ "must be a PDF" ] }
          )
        end

        if byte_size.to_i > MAX_BYTES
          raise Api::Error::UnprocessableEntity.new(
            "File too large", details: { file: [ "must be 5 MB or less" ] }
          )
        end
      end

      def reader
        @reader ||= PDF::Reader.new(io)
      end

      def pages_count
        reader.page_count
      end

      def extract_text
        reader.pages.map(&:text).join("\n").first(MAX_RAW_TEXT).to_s
      rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError, ArgumentError => e
        raise Api::Error::UnprocessableEntity.new(
          "Could not read PDF", details: { file: [ e.message ] }
        )
      end
    end
  end
end
