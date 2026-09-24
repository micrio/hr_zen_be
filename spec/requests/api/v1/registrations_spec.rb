# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /api/v1/sign_up", type: :request do
  let(:params) do
    {
      organization: { name: "Acme Inc", email: "hello@acme.test", subdomain: "acme" },
      user: {
        email: "owner@acme.test",
        first_name: "Jane",
        last_name: "Doe",
        password: "password123",
        password_confirmation: "password123"
      }
    }
  end

  describe "with valid params" do
    subject(:request) { post "/api/v1/sign_up", params: params, as: :json }

    it "creates the workspace and enqueues the setup job" do
      expect { request }
        .to change(Organization, :count).by(1)
        .and change(User, :count).by(1)
        .and have_enqueued_job(SetupWorkspaceJob)
    end

    it "returns a 201 with the JSON API envelope" do
      request

      expect(response).to have_http_status(:created)
      expect(response_body["success"]).to be true
      expect(response_body.dig("data", "organization", "subdomain")).to eq("acme")
      expect(response_body.dig("data", "user", "email")).to eq("owner@acme.test")
      expect(response_body["meta"]["message"]).to be_present
    end
  end

  describe "with invalid user params" do
    it "returns 422 with field-level details" do
      params[:user][:password_confirmation] = "mismatch"

      expect { post "/api/v1/sign_up", params: params, as: :json }
        .not_to change(Organization, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["success"]).to be false
      expect(response_body["error"]).to eq("Validation failed")
      expect(response_body["details"]).to have_key("password_confirmation")
    end
  end

  describe "with an already taken subdomain" do
    before { create(:organization, subdomain: "acme") }

    it "returns 422" do
      post "/api/v1/sign_up", params: params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("subdomain")
    end
  end

  describe "with a missing payload" do
    it "returns 400" do
      post "/api/v1/sign_up", params: { organization: params[:organization] }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(response_body["success"]).to be false
    end
  end
end
