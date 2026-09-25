# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  def admin_for(plan)
    organization = create(:organization, plan: plan)
    AuthMatrix::Initializer.setup_workspace!(organization)
    admin = create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
    [ organization, admin ]
  end

  it "returns plan-filtered cards and saves the layout" do
    _organization, admin = admin_for("enterprise")

    get "/api/v1/dashboard", headers: auth_headers(admin), as: :json

    expect(response).to have_http_status(:ok)
    expect(response_body.dig("data", "cards")).to include("headcount", "payroll_net", "holidays")
    expect(response_body.dig("data", "layout")).to eq([])

    patch "/api/v1/dashboard",
          params: { layout: [ { key: "headcount", span: "sm" }, { key: "payroll_net", span: "lg" } ] },
          headers: auth_headers(admin),
          as: :json

    expect(response).to have_http_status(:ok)
    expect(response_body.dig("data", "layout").length).to eq(2)

    get "/api/v1/dashboard", headers: auth_headers(admin), as: :json
    expect(response_body.dig("data", "layout").first["key"]).to eq("headcount")
  end

  it "hides cards the plan does not include" do
    _organization, admin = admin_for("free")

    get "/api/v1/dashboard", headers: auth_headers(admin), as: :json

    cards = response_body.dig("data", "cards")
    expect(cards.keys).to eq([ "headcount" ])
  end

  it "drops unknown cards and bad spans" do
    _organization, admin = admin_for("enterprise")

    patch "/api/v1/dashboard",
          params: { layout: [ { key: "nope", span: "sm" }, { key: "headcount", span: "huge" } ] },
          headers: auth_headers(admin),
          as: :json

    expect(response_body.dig("data", "layout")).to eq([])
  end
end
