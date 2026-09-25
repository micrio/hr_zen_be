# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User custom fields (from the 'User' record type)", type: :request do
  let(:organization) { create(:organization) }

  before do
    AuthMatrix::Initializer.setup_workspace!(organization)

    ActsAsTenant.with_tenant(organization) do
      record_type = RecordType.find_by!(name: "User")
      record_type.update!(
        fields: record_type.field_definitions + [
          { "key" => "age", "label" => "Age", "type" => "number", "level" => 0, "required" => false },
          { "key" => "gender", "label" => "Gender", "type" => "select", "level" => 0, "required" => false, "options" => %w[male female] }
        ]
      )
    end
  end

  let(:admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end
  let(:headers) { auth_headers(admin) }

  describe "POST /api/v1/users" do
    it "stores validated custom fields" do
      admin

      post "/api/v1/users",
           params: {
             user: {
               email: "custom@example.com",
               first_name: "Cus",
               last_name: "Tom",
               password: "password123",
               password_confirmation: "password123",
               custom_fields: { age: "30", gender: "female" }
             },
             role_names: [ "employee" ]
           },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "custom_fields", "age")).to eq(30.0)
      expect(response_body.dig("data", "custom_fields", "gender")).to eq("female")
    end

    it "rejects core fields passed as custom fields" do
      admin

      post "/api/v1/users",
           params: {
             user: {
               email: "custom2@example.com",
               first_name: "Cus",
               last_name: "Tom",
               password: "password123",
               password_confirmation: "password123",
               custom_fields: { first_name: "Nope" }
             }
           },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]["first_name"]).to include("is not a defined field")
    end

    it "rejects level-2 sensitive fields as custom fields" do
      admin

      post "/api/v1/users",
           params: {
             user: {
               email: "custom3@example.com",
               first_name: "Cus",
               last_name: "Tom",
               password: "password123",
               password_confirmation: "password123",
               custom_fields: { encrypted_password: "hack" }
             }
           },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]["encrypted_password"]).to include("is not a defined field")
    end
  end

  describe "PATCH /api/v1/users/:id" do
    it "merges custom fields" do
      admin
      target = ActsAsTenant.with_tenant(organization) do
        create(:user, organization: organization, custom_fields: { "age" => 30.0, "gender" => "male" })
      end

      patch "/api/v1/users/#{target.id}",
            params: { user: { custom_fields: { age: "31" } } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "custom_fields", "age")).to eq(31.0)
      expect(response_body.dig("data", "custom_fields", "gender")).to eq("male")
    end
  end
end
