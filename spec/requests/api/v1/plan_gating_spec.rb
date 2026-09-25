# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Plan gating", type: :request do
  def org_with_admin(plan)
    organization = create(:organization, plan: plan)
    admin = create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
    [ organization, admin ]
  end

  context "free plan" do
    let(:organization) { create(:organization, plan: "free") }
    let(:admin) do
      create(:user, organization: organization).tap do |user|
        ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
      end
    end
    let(:headers) { auth_headers(admin) }

    before { AuthMatrix::Initializer.setup_workspace!(organization) }

    it "allows user management" do
      get "/api/v1/users", headers: headers, as: :json
      expect(response).to have_http_status(:ok)
    end

    it "blocks attendance, roles and work" do
      get "/api/v1/attendance/setting", headers: headers, as: :json
      expect(response).to have_http_status(:forbidden)

      get "/api/v1/roles", headers: headers, as: :json
      expect(response).to have_http_status(:forbidden)

      get "/api/v1/teams", headers: headers, as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "caps users at 5" do
      admin # ensure the admin exists (1 user)
      3.times { create(:user, organization: organization) } # now 4

      post "/api/v1/users",
           params: {
             user: {
               email: "fifth@example.com", first_name: "Five", last_name: "User",
               password: "password123", password_confirmation: "password123"
             }
           },
           headers: headers,
           as: :json
      expect(response).to have_http_status(:created)

      post "/api/v1/users",
           params: {
             user: {
               email: "sixth@example.com", first_name: "Six", last_name: "User",
               password: "password123", password_confirmation: "password123"
             }
           },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["error"]).to eq("Plan user limit reached")
    end
  end

  context "pro plan" do
    let(:organization) { create(:organization, plan: "pro") }
    let(:admin) do
      create(:user, organization: organization).tap do |user|
        ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
      end
    end
    let(:headers) { auth_headers(admin) }

    before { AuthMatrix::Initializer.setup_workspace!(organization) }

    it "allows attendance/leaves/payroll but not work" do
      get "/api/v1/attendance/setting", headers: headers, as: :json
      expect(response).to have_http_status(:ok)

      get "/api/v1/leave_types", headers: headers, as: :json
      expect(response).to have_http_status(:ok)

      get "/api/v1/payroll/setting", headers: headers, as: :json
      expect(response).to have_http_status(:ok)

      get "/api/v1/projects", headers: headers, as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "enterprise plan" do
    let(:organization) { create(:organization, plan: "enterprise") }
    let(:admin) do
      create(:user, organization: organization).tap do |user|
        ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
      end
    end
    let(:headers) { auth_headers(admin) }

    before { AuthMatrix::Initializer.setup_workspace!(organization) }

    it "allows work management" do
      get "/api/v1/projects", headers: headers, as: :json
      expect(response).to have_http_status(:ok)

      get "/api/v1/tasks", headers: headers, as: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
