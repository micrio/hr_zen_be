# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PermissionRules", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:superadmin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("superadmin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(superadmin) }

  def role_named(name)
    ActsAsTenant.with_tenant(organization) { Role.find_by!(name: name) }
  end

  def record_type_named(name)
    ActsAsTenant.with_tenant(organization) { RecordType.find_by!(name: name) }
  end

  describe "GET /api/v1/permission_rules" do
    it "lists rules and filters by role" do
      superadmin
      role = role_named("employee")

      get "/api/v1/permission_rules?role_id=#{role.id}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body["data"]).not_to be_empty
      expect(response_body["data"].map { |rule| rule["role_id"] }.uniq).to eq([ role.id ])
      expect(response_body["data"].first).to include(
        "perm_level", "can_read", "can_write", "apply_user_permissions"
      )
    end

    it "forbids non-superadmins" do
      get "/api/v1/permission_rules", headers: auth_headers(member), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/permission_rules" do
    it "creates a rule with action flags" do
      superadmin
      role = role_named("employee")
      record_type = record_type_named("User")

      expect do
        post "/api/v1/permission_rules",
             params: {
               permission_rule: {
                 role_id: role.id,
                 record_type_id: record_type.id,
                 perm_level: 1,
                 can_read: true,
                 can_write: false,
                 can_export: true
               }
             },
             headers: headers,
             as: :json
      end.to change(PermissionRule, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "can_read")).to be true
      expect(response_body.dig("data", "can_export")).to be true
      expect(response_body.dig("data", "can_write")).to be false
    end

    it "rejects a duplicate role/record_type/perm_level" do
      superadmin
      role = role_named("employee")
      record_type = record_type_named("LeaveApplication")

      post "/api/v1/permission_rules",
           params: {
             permission_rule: {
               role_id: role.id,
               record_type_id: record_type.id,
               perm_level: 0
             }
           },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("perm_level")
    end
  end

  describe "PATCH /api/v1/permission_rules/:id" do
    it "toggles action flags" do
      superadmin
      rule = ActsAsTenant.with_tenant(organization) { PermissionRule.readable.first }

      patch "/api/v1/permission_rules/#{rule.id}",
            params: { permission_rule: { can_export: true, can_read: false } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "can_export")).to be true
      expect(response_body.dig("data", "can_read")).to be false
    end
  end

  describe "DELETE /api/v1/permission_rules/:id" do
    it "deletes a rule" do
      superadmin
      rule = ActsAsTenant.with_tenant(organization) { PermissionRule.first }

      expect do
        delete "/api/v1/permission_rules/#{rule.id}", headers: headers, as: :json
      end.to change(PermissionRule, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end
  end
end
