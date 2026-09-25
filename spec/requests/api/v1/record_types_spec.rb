# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RecordTypes", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(admin) }

  def record_type_named(name)
    ActsAsTenant.with_tenant(organization) { RecordType.find_by!(name: name) }
  end

  describe "GET /api/v1/record_types" do
    it "lists record types with field levels" do
      admin

      get "/api/v1/record_types", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      names = response_body["data"].map { |record_type| record_type["name"] }
      expect(names).to match_array(%w[User EmployeeProfile LeaveApplication SalarySlip])
      expect(response_body["data"].first).to include("field_levels")
    end

    it "forbids non-admins" do
      get "/api/v1/record_types", headers: auth_headers(member), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/record_types" do
    it "creates a record type" do
      admin

      expect do
        post "/api/v1/record_types",
             params: {
               record_type: {
                 name: "Expense",
                 fields: [
                   { key: "amount", label: "Amount", type: "number", level: 1, required: true }
                 ]
               }
             },
             headers: headers,
             as: :json
      end.to change(RecordType, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "fields").first["key"]).to eq("amount")
      expect(response_body.dig("data", "field_levels")).to eq("amount" => 1)
    end
  end

  describe "PATCH /api/v1/record_types/:id" do
    it "updates the field definitions" do
      admin
      record_type = record_type_named("User")

      patch "/api/v1/record_types/#{record_type.id}",
            params: {
              record_type: {
                fields: [
                  { key: "encrypted_password", label: "Password", type: "text", level: 2, required: false },
                  { key: "email", label: "Email", type: "text", level: 0, required: true }
                ]
              }
            },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "field_levels")).to eq(
        "encrypted_password" => 2, "email" => 0
      )
      expect(response_body.dig("data", "fields").map { |f| f["key"] }).to eq(
        %w[encrypted_password email]
      )
    end
  end

  describe "DELETE /api/v1/record_types/:id" do
    it "refuses to delete a record type with permission rules" do
      admin
      record_type = record_type_named("EmployeeProfile")

      delete "/api/v1/record_types/#{record_type.id}", headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "deletes a record type without permission rules" do
      admin
      record_type = record_type_named("SalarySlip")

      expect do
        delete "/api/v1/record_types/#{record_type.id}", headers: headers, as: :json
      end.to change(RecordType, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end
  end
end
