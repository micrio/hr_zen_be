# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /api/v1/users/me", type: :request do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization) }

  def bearer_token_for(user)
    token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
    token
  end

  describe "without a token" do
    it "returns 401" do
      get "/api/v1/users/me", as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "with a valid bearer token" do
    it "returns the current user and organization" do
      get "/api/v1/users/me",
          headers: { "Authorization" => "Bearer #{bearer_token_for(user)}" },
          as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "user", "email")).to eq(user.email)
      expect(response_body.dig("data", "organization", "id")).to eq(organization.id)
    end

    it "allows an unconfirmed user while the confirmation flow is pending" do
      unconfirmed = build(:user, :unconfirmed, organization: organization)
      unconfirmed.skip_confirmation_notification!
      unconfirmed.save!

      get "/api/v1/users/me",
          headers: { "Authorization" => "Bearer #{bearer_token_for(unconfirmed)}" },
          as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "user", "confirmed_at")).to be_nil
    end
  end
end
