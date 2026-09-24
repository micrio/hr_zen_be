# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SignUpService do
  subject(:service) { described_class.new(organization: organization_params, user: user_params) }

  let(:organization_params) do
    { name: "Acme Inc", email: "hello@acme.test", subdomain: "acme", phone: "+15551234567" }
  end
  let(:user_params) do
    {
      email: "owner@acme.test",
      first_name: "Jane",
      middle_name: nil,
      last_name: "Doe",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  describe "#perform" do
    it "creates the organization and its owner user" do
      expect { service.perform }
        .to change(Organization, :count).by(1)
        .and change(User, :count).by(1)
    end

    it "returns the created user" do
      user = service.perform

      expect(user).to be_a(User)
      expect(user.email).to eq("owner@acme.test")
      expect(user.uuid).to be_present
    end

    it "links the user to the organization as owner" do
      user = service.perform

      expect(user.organization.subdomain).to eq("acme")
      expect(user.organization.owner).to eq(user)
    end

    it "does not send the confirmation email yet" do
      expect(Devise.mailer).not_to receive(:confirmation_instructions)

      service.perform
    end

    context "when the subdomain is already taken" do
      before { create(:organization, subdomain: "acme") }

      it "raises and rolls back the whole transaction" do
        expect { service.perform }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Organization.count).to eq(1)
        expect(User.count).to eq(0)
      end
    end

    context "when the password confirmation does not match" do
      let(:user_params) { super().merge(password_confirmation: "nope") }

      it "raises and rolls back the organization" do
        expect { service.perform }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Organization.count).to eq(0)
        expect(User.count).to eq(0)
      end
    end

    context "when the email is already taken" do
      before { create(:user, email: "owner@acme.test") }

      it "raises and rolls back the new organization" do
        expect { service.perform }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Organization.count).to eq(1)
        expect(User.count).to eq(1)
      end
    end
  end
end
