# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization, type: :model do
  subject(:organization) { build(:organization) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:subdomain) }
  it { is_expected.to have_many(:users).dependent(:destroy) }

  describe "uuid" do
    it "is generated before create" do
      organization.save!

      expect(organization.uuid).to be_present
    end
  end

  describe "subdomain" do
    it "rejects invalid characters" do
      organization.subdomain = "Acme Inc"

      expect(organization).not_to be_valid
      expect(organization.errors[:subdomain]).to be_present
    end

    it "is unique across organizations" do
      create(:organization, subdomain: "acme")
      organization.subdomain = "acme"

      expect(organization).not_to be_valid
    end
  end
end
