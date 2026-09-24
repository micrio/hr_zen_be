# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SignInService do
  subject(:service) { described_class.new(email: email, password: password) }

  let(:organization) { create(:organization) }
  let!(:user) do
    create(:user, organization: organization, email: "owner@acme.test", password: "password123")
  end

  let(:email) { "owner@acme.test" }
  let(:password) { "password123" }

  describe "#perform" do
    it "returns the matching user" do
      expect(service.perform).to eq(user)
    end

    it "normalizes the email (case/whitespace)" do
      expect(described_class.new(email: "  OWNER@Acme.test  ", password: password).perform).to eq(user)
    end

    context "when the password is wrong" do
      let(:password) { "nope" }

      it "raises UnauthorizedError" do
        expect { service.perform }.to raise_error(Api::Error::UnauthorizedError)
      end
    end

    context "when the email is unknown" do
      let(:email) { "ghost@acme.test" }

      it "raises UnauthorizedError" do
        expect { service.perform }.to raise_error(Api::Error::UnauthorizedError)
      end
    end
  end
end
