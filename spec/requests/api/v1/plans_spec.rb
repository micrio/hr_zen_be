# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /api/v1/plans", type: :request do
  let(:organization) { create(:organization) }
  let(:platform_admin) do
    create(:user, organization: organization, platform_admin: true)
  end
  let(:org_admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  it "returns the tier catalogue for the platform admin" do
    get "/api/v1/plans", headers: auth_headers(platform_admin), as: :json

    expect(response).to have_http_status(:ok)
    plans = response_body["data"].index_by { |row| row["plan"] }

    expect(plans.keys).to match_array(%w[free pro enterprise])
    expect(plans["free"]["features"]).to eq([ "users" ])
    expect(plans["free"]["limits"]["users"]).to eq(5)
    expect(plans["enterprise"]["features"]).to include("work")
    expect(plans["enterprise"]["limits"]["users"]).to be_nil
  end

  it "forbids a regular org admin" do
    get "/api/v1/plans", headers: auth_headers(org_admin), as: :json

    expect(response).to have_http_status(:forbidden)
  end
end
