# frozen_string_literal: true

require "rails_helper"

RSpec.describe "db/seeds" do
  let(:email) { "superadmin@hrzen.test" }

  it "creates the platform superadmin and is idempotent" do
    expect { load Rails.root.join("db/seeds.rb") }.to change(User, :count).by(1)
    expect { load Rails.root.join("db/seeds.rb") }.not_to change(User, :count)

    user = User.find_by!(email: email)

    expect(user.platform_admin?).to be true
    expect(user.confirmed?).to be true

    ActsAsTenant.with_tenant(user.organization) do
      expect(user.roles.pluck(:name)).to include("admin")
    end
  end

  it "seeds an organization on the enterprise plan" do
    load Rails.root.join("db/seeds.rb")

    organization = Organization.find_by!(subdomain: "hr-zen")
    expect(organization.plan).to eq("enterprise")
    expect(organization.owner).to be_present
  end
end
