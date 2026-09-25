# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Roles", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(admin) }

  def role_named(name)
    ActsAsTenant.with_tenant(organization) { Role.find_by!(name: name) }
  end

  describe "GET /api/v1/roles" do
    it "lists the tenant roles with counts" do
      admin

      get "/api/v1/roles", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      names = response_body["data"].map { |role| role["name"] }
      expect(names).to match_array(%w[admin hr_manager leave_approver employee])
      expect(response_body["data"].first).to include("users_count", "permission_rules_count")
    end

    it "does not leak roles from other organizations" do
      other_role = nil
      ActsAsTenant.with_tenant(create(:organization)) do
        other_role = create(:role, name: "outsider")
      end
      admin

      get "/api/v1/roles", headers: headers, as: :json

      expect(response_body["data"].map { |role| role["id"] }).not_to include(other_role.id)
    end

    it "forbids non-admins" do
      get "/api/v1/roles", headers: auth_headers(member), as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it "requires authentication" do
      get "/api/v1/roles", as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/roles" do
    it "creates a role" do
      admin

      expect do
        post "/api/v1/roles", params: { role: { name: "payroll_admin" } }, headers: headers, as: :json
      end.to change(Role, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "name")).to eq("payroll_admin")
    end

    it "rejects a duplicate name" do
      admin

      post "/api/v1/roles", params: { role: { name: "employee" } }, headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("name")
    end
  end

  describe "PATCH /api/v1/roles/:id" do
    it "renames a role" do
      admin
      role = role_named("employee")

      patch "/api/v1/roles/#{role.id}", params: { role: { name: "staff" } }, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "name")).to eq("staff")
    end
  end

  describe "DELETE /api/v1/roles/:id" do
    it "deletes an unassigned role" do
      admin
      role = role_named("employee")

      expect do
        delete "/api/v1/roles/#{role.id}", headers: headers, as: :json
      end.to change(Role, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it "refuses to delete a system role" do
      admin
      role = role_named("admin")

      delete "/api/v1/roles/#{role.id}", headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "refuses to delete a role assigned to users" do
      admin
      role = role_named("employee")
      ActsAsTenant.with_tenant(organization) { member.assign_role("employee") }

      delete "/api/v1/roles/#{role.id}", headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
