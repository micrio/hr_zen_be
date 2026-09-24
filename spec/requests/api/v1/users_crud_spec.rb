# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users CRUD", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:superadmin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("superadmin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(superadmin) }

  describe "GET /api/v1/users" do
    it "lists users of the organization with pagination meta" do
      superadmin
      member

      get "/api/v1/users", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      emails = response_body["data"].map { |u| u["email"] }
      expect(emails).to match_array([ superadmin.email, member.email ])
      expect(response_body["meta"]).to include("page", "per_page", "total")
    end

    it "does not leak users from other organizations" do
      outsider = create(:user, organization: create(:organization))
      superadmin

      get "/api/v1/users", headers: headers, as: :json

      expect(response_body["data"].map { |u| u["id"] }).not_to include(outsider.id)
    end

    it "filters by query" do
      superadmin
      create(:user, organization: organization, first_name: "Zelda", email: "zelda@example.com")

      get "/api/v1/users?query=zelda", headers: headers, as: :json

      expect(response_body["data"].map { |u| u["email"] }).to eq([ "zelda@example.com" ])
    end

    it "forbids non-superadmins" do
      get "/api/v1/users", headers: auth_headers(member), as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it "requires authentication" do
      get "/api/v1/users", as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/users" do
    let(:params) do
      {
        user: {
          email: "newbie@example.com",
          first_name: "New",
          last_name: "Bie",
          password: "password123",
          password_confirmation: "password123"
        },
        role_names: [ "employee" ]
      }
    end

    it "creates a user in the organization with roles" do
      superadmin

      expect { post "/api/v1/users", params: params, headers: headers, as: :json }
        .to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "email")).to eq("newbie@example.com")
      expect(response_body.dig("data", "role_names")).to eq([ "employee" ])
    end

    it "stores age and gender" do
      superadmin
      params[:user][:age] = 30
      params[:user][:gender] = "female"

      post "/api/v1/users", params: params, headers: headers, as: :json

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "age")).to eq(30)
      expect(response_body.dig("data", "gender")).to eq("female")
    end

    it "rejects an out-of-range age" do
      superadmin
      params[:user][:age] = 999

      post "/api/v1/users", params: params, headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("age")
    end

    it "rejects an invalid payload" do
      superadmin
      params[:user][:password_confirmation] = "mismatch"

      post "/api/v1/users", params: params, headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("password_confirmation")
    end
  end

  describe "PATCH /api/v1/users/:id" do
    it "updates attributes and roles" do
      target = create(:user, organization: organization)

      patch "/api/v1/users/#{target.id}",
            params: { user: { first_name: "Updated" }, role_names: [ "hr_manager" ] },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "first_name")).to eq("Updated")
      expect(response_body.dig("data", "role_names")).to eq([ "hr_manager" ])
    end

    it "keeps the password when blank" do
      target = create(:user, organization: organization)
      original = target.encrypted_password

      patch "/api/v1/users/#{target.id}",
            params: { user: { password: "", password_confirmation: "" } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(target.reload.encrypted_password).to eq(original)
    end

    it "returns 404 for a user in another organization" do
      outsider = create(:user, organization: create(:organization))

      patch "/api/v1/users/#{outsider.id}",
            params: { user: { first_name: "Nope" } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/users/:id" do
    it "deletes a user" do
      superadmin
      target = create(:user, organization: organization)

      expect do
        delete "/api/v1/users/#{target.id}", headers: headers, as: :json
      end.to change(User, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it "refuses to delete the current user" do
      delete "/api/v1/users/#{superadmin.id}", headers: headers, as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it "forbids non-superadmins" do
      target = create(:user, organization: organization)

      delete "/api/v1/users/#{target.id}", headers: auth_headers(member), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end
end
