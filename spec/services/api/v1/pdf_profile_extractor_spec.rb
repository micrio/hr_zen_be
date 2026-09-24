# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::PdfProfileExtractor do
  describe ".parse_text" do
    it "extracts labelled fields and normalizes the email" do
      text = <<~TEXT
        First Name: John
        Last Name: Doe
        Email: JOHN@Example.com
        Phone: +1 (555) 123-4567
      TEXT

      fields = described_class.parse_text(text)

      expect(fields[:first_name]).to eq("John")
      expect(fields[:last_name]).to eq("Doe")
      expect(fields[:email]).to eq("john@example.com")
      expect(fields[:phone]).to include("555")
    end

    it "extracts a name from the first name-like line" do
      fields = described_class.parse_text("Jane Q Smith\njane@example.com\n")

      expect(fields[:first_name]).to eq("Jane")
      expect(fields[:middle_name]).to eq("Q")
      expect(fields[:last_name]).to eq("Smith")
    end

    it "returns only the fields it finds" do
      expect(described_class.parse_text("no useful info here")).to eq({})
    end
  end
end
