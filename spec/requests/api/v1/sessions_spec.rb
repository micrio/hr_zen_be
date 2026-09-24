# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /api/v1/sign_in", type: :request do
  let(:organization) { create(:organization) }
  let!(:user) do
    create(:user, organization: organization, email: "owner@acme.test", password: "password123")
  end

  let(:params) { { user: { email: "owner@acme.test", password: "password123" } } }

  describe "with valid credentials" do
    it "returns the user, organization and a bearer token" do
      post "/api/v1/sign_in", params: params, as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body["success"]).to be true
      expect(response_body.dig("data", "user", "email")).to eq("owner@acme.test")
      expect(response_body.dig("data", "organization", "id")).to eq(organization.id)
      expect(response_body.dig("data", "token")).to be_present
    end
  end

  describe "with a wrong password" do
    it "returns 401 without leaking which field failed" do
      params[:user][:password] = "wrong"

      post "/api/v1/sign_in", params: params, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response_body["success"]).to be false
      expect(response_body["error"]).to eq("Invalid email or password")
    end
  end

  describe "with a missing payload" do
    it "returns 400" do
      post "/api/v1/sign_in", params: {}, as: :json

      expect(response).to have_http_status(:bad_request)
    end
  end
end
