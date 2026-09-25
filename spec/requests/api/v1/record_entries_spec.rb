# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RecordEntries", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(admin) }

  let(:record_type) do
    ActsAsTenant.with_tenant(organization) do
      RecordType.create!(
        name: "Expense",
        fields: [
          { "key" => "amount", "label" => "Amount", "type" => "number", "level" => 1, "required" => true },
          { "key" => "note", "label" => "Note", "type" => "text", "level" => 0, "required" => false }
        ]
      )
    end
  end

  describe "POST /api/v1/record_entries" do
    it "creates an entry, coercing values by field type" do
      admin

      expect do
        post "/api/v1/record_entries",
             params: { record_entry: { record_type_id: record_type.id, data: { amount: "120.5", note: "lunch" } } },
             headers: headers,
             as: :json
      end.to change(RecordEntry, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "data", "amount")).to eq(120.5)
      expect(response_body.dig("data", "data", "note")).to eq("lunch")
    end

    it "rejects a missing required field" do
      admin

      post "/api/v1/record_entries",
           params: { record_entry: { record_type_id: record_type.id, data: { note: "x" } } },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]["amount"]).to include("is required")
    end

    it "rejects a value that fails type coercion" do
      admin

      post "/api/v1/record_entries",
           params: { record_entry: { record_type_id: record_type.id, data: { amount: "abc" } } },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]["amount"]).to include("is invalid")
    end

    it "rejects undefined fields" do
      admin

      post "/api/v1/record_entries",
           params: { record_entry: { record_type_id: record_type.id, data: { amount: 1, ghost: "x" } } },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]["ghost"]).to include("is not a defined field")
    end
  end

  describe "GET /api/v1/record_entries" do
    it "lists entries filtered by record type" do
      admin
      entry = ActsAsTenant.with_tenant(organization) do
        RecordEntry.create!(record_type: record_type, data: { "amount" => 10.0 })
      end

      get "/api/v1/record_entries?record_type_id=#{record_type.id}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body["data"].map { |e| e["id"] }).to eq([ entry.id ])
    end

    it "forbids non-admins" do
      get "/api/v1/record_entries", headers: auth_headers(member), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/record_entries/:id" do
    it "merges and re-validates the data" do
      admin
      entry = ActsAsTenant.with_tenant(organization) do
        RecordEntry.create!(record_type: record_type, data: { "amount" => 10.0, "note" => "old" })
      end

      patch "/api/v1/record_entries/#{entry.id}",
            params: { record_entry: { data: { note: "new" } } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "data", "amount")).to eq(10.0)
      expect(response_body.dig("data", "data", "note")).to eq("new")
    end
  end

  describe "DELETE /api/v1/record_entries/:id" do
    it "deletes an entry" do
      admin
      entry = ActsAsTenant.with_tenant(organization) do
        RecordEntry.create!(record_type: record_type, data: { "amount" => 10.0 })
      end

      expect do
        delete "/api/v1/record_entries/#{entry.id}", headers: headers, as: :json
      end.to change(RecordEntry, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end
  end
end
