# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to have_many(:user_roles).dependent(:destroy) }

  describe "uuid" do
    it "is generated before create" do
      user.save!

      expect(user.uuid).to be_present
    end
  end

  describe "#full_name" do
    it "joins the name parts" do
      user.assign_attributes(first_name: "Jane", middle_name: "Q", last_name: "Doe")

      expect(user.full_name).to eq("Jane Q Doe")
    end

    it "ignores blank parts" do
      user.assign_attributes(first_name: "Jane", middle_name: nil, last_name: "Doe")

      expect(user.full_name).to eq("Jane Doe")
    end
  end

  describe "#assign_role" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }

    before do
      ActsAsTenant.with_tenant(organization) { create(:role, name: "employee") }
    end

    it "assigns an existing tenant role" do
      ActsAsTenant.with_tenant(organization) { user.assign_role("Employee") }

      ActsAsTenant.with_tenant(organization) do
        expect(user.reload.has_role?("employee")).to be true
      end
    end

    it "raises when the role does not exist" do
      ActsAsTenant.with_tenant(organization) do
        expect { user.assign_role("ghost") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
