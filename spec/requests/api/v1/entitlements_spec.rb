# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /api/v1/entitlements", type: :request do
  def admin_for(plan)
    organization = create(:organization, plan: plan)
    AuthMatrix::Initializer.setup_workspace!(organization)
    admin = create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
    [ organization, admin ]
  end

  it "returns the free-tier features and user limit" do
    _organization, admin = admin_for("free")

    get "/api/v1/entitlements", headers: auth_headers(admin), as: :json

    expect(response).to have_http_status(:ok)
    expect(response_body.dig("data", "plan")).to eq("free")
    expect(response_body.dig("data", "features")).to eq([ "users" ])
    expect(response_body.dig("data", "limits", "users")).to eq(5)
  end

  it "returns all features and no user limit for enterprise" do
    _organization, admin = admin_for("enterprise")

    get "/api/v1/entitlements", headers: auth_headers(admin), as: :json

    features = response_body.dig("data", "features")
    expect(features).to include("attendance", "payroll", "work")
    expect(response_body.dig("data", "limits", "users")).to be_nil
  end

  it "requires authentication" do
    get "/api/v1/entitlements", as: :json

    expect(response).to have_http_status(:unauthorized)
  end
end
