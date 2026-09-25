# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organizations (SaaS superadmin)", type: :request do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }

  let(:platform_admin) do
    create(:user, organization: organization, platform_admin: true)
  end
  let(:org_admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end
  let(:member) { create(:user, organization: organization) }

  before do
    AuthMatrix::Initializer.setup_workspace!(organization)
    other_organization
  end

  describe "GET /api/v1/organizations" do
    it "lists every organization with plan and user counts for the platform admin" do
      get "/api/v1/organizations", headers: auth_headers(platform_admin), as: :json

      expect(response).to have_http_status(:ok)
      ids = response_body["data"].map { |o| o["id"] }
      expect(ids).to include(organization.id, other_organization.id)
      expect(response_body["data"].first).to include("plan", "users_count", "subdomain", "features", "limits")
    end

    it "counts users without the tenant scope leaking" do
      ActsAsTenant.with_tenant(other_organization) { create_list(:user, 3) }

      get "/api/v1/organizations", headers: auth_headers(platform_admin), as: :json

      row = response_body["data"].find { |o| o["id"] == other_organization.id }
      expect(row["users_count"]).to eq(3)
    end

    it "forbids a regular org admin" do
      get "/api/v1/organizations", headers: auth_headers(org_admin), as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it "forbids a member" do
      get "/api/v1/organizations", headers: auth_headers(member), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/organizations/:id" do
    it "lets the platform admin change the plan" do
      patch "/api/v1/organizations/#{organization.id}",
            params: { organization: { plan: "pro" } },
            headers: auth_headers(platform_admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "plan")).to eq("pro")
      expect(organization.reload.plan).to eq("pro")
    end

    it "rejects an unknown plan" do
      patch "/api/v1/organizations/#{organization.id}",
            params: { organization: { plan: "platinum" } },
            headers: auth_headers(platform_admin),
            as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("plan")
    end

    it "counts users without the tenant scope leaking" do
      ActsAsTenant.with_tenant(other_organization) { create_list(:user, 3) }

      get "/api/v1/organizations", headers: auth_headers(platform_admin), as: :json

      row = response_body["data"].find { |o| o["id"] == other_organization.id }
      expect(row["users_count"]).to eq(3)
    end

    it "forbids a regular org admin" do
      patch "/api/v1/organizations/#{organization.id}",
            params: { organization: { plan: "pro" } },
            headers: auth_headers(org_admin),
            as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end
end
